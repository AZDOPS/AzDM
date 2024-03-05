# Install required modules
$RequiredModules = @('ADOPS','yapg','Az.Accounts','Az.Resources')
Install-Module -Name $RequiredModules

# Variables
## Azure Variables
$EntraTenantID = 'ac43c664-47cf-4e61-8d98-2076604ce26f'
$AzureSubsciptionId = 'aeef726e-ec71-4cb3-a529-9e898faec9f3'
$AzureVMSSResourceGroupName = 'AzDMAutoTest'
$ResourceLocation = 'WestEurope'
$VMSSAdminUserName = 'SuperAdmin'
$VMSSAdminPassword = New-YapgPassword -AddChars -Capitalize -Leet

## Azure DevOps Variables
$AzureDevOpsOrganizationName = 'bjornsundling'
$AzureDevOpsAzDMProject = @{
    Name = 'AzDMAutoTest'
    Description = 'AzDM Manager project.'
    ProcessTypeName = 'Basic'
    Visibility = 'Private'
}
$AzureDevOpsAzDMRepo = 'AzDM'

# Connect to your Azure DevOps and Azure resources
Connect-AzAccount -Subscription $AzureSubsciptionId -Tenant $EntraTenantID
Connect-ADOPS -Organization $AzureDevOpsOrganizationName -TenantId $EntraTenantID

#region Set up Azure Infrastructure
# Deploy VMSS and network
$RG = New-AzResourceGroup -Name $AzureVMSSResourceGroupName -Location $ResourceLocation
$Network = New-AzResourceGroupDeployment -Name 'VMSSNetworkDeploy' -ResourceGroupName $AzureVMSSResourceGroupName -TemplateFile .\bicepTemplates\network.bicep
$VMSS = New-AzResourceGroupDeployment -Name 'VMSSDeploy' -ResourceGroupName $AzureVMSSResourceGroupName -TemplateFile .\bicepTemplates\VMSS.bicep -TemplateParameterObject @{
    adminUserName = $VMSSAdminUserName
    subnetId = $Network.Outputs['subnetId'].Value
    adminPassword = $VMSSAdminPassword
}
#endregion

#region Add managed identity to Azure DevOps
# Add the managed identity to your Azure DevOps organization
$VMSSIdentity = $vmss.Outputs['idetity'].Value
$uri = "https://vssps.dev.azure.com/$AzureDevOpsOrganizationName/_apis/graph/serviceprincipals?api-version=7.1-preview.1"
$body = "{""originId"": ""$($VMSSIdentity)""}"
$User = Invoke-ADOPSRestMethod -Uri $uri -Method Post -Body $body

## Add a license to the managed identity
$Uri = "https://vsaex.dev.azure.com/$AzureDevOpsOrganizationName/_apis/serviceprincipalentitlements?api-version=7.1-preview.1"
$body = @{
    accessLevel         = @{
        licenseDisplayName = "Basic"
        accountLicenseType = 2
    }
    servicePrincipal    = @{
        origin      = $($user.origin)
        originId    = $($user.originId)
        subjectKind = $($user.subjectKind)
    }
} | ConvertTo-Json -Compress 
$License = Invoke-ADOPSRestMethod -Uri $uri -Method Post -Body $body 

## Add user to the Project collection administrators group. This will grant highest access to this identity!
$Group = Get-ADOPSGroup | Where-Object -Property principalName -EQ "[$AzureDevOpsOrganizationName]\Project Collection Administrators" 
$Uri = "https://vssps.dev.azure.com/$AzureDevOpsOrganizationName/_apis/Graph/ServicePrincipals?groupDescriptors=$($Group.descriptor)&api-version=7.1-preview.1"
$Body = "{""originId"":""$($User.originId)""}"
$GroupMembership = Invoke-ADOPSRestMethod -Uri $Uri -Method Post -Body $Body

#endregion

#region Create AzDM Project
$AzDMProject = Get-ADOPSProject -Name $AzureDevOpsAzDMProject
if (-not ($AzDMProject)) {
    $AzDMProject = New-ADOPSProject @AzureDevOpsAzDMProject -Wait
}
#endregion

# TODO: Add create pool!

#region Create and import the AzDM repository
$Repo = Get-ADOPSRepository -Project $AzDMProject.Name -Repository $AzureDevOpsAzDMRepo
if ($null -eq $Repo) {
    $Repo = New-ADOPSRepository -Project $AzDMProject.Name -Name $AzureDevOpsAzDMRepo 
}

# Import the AzDM repo
$null = Import-ADOPSRepository -Project $AzDMProject.Name -RepositoryName $Repo.name -GitSource 'TODO:Insert correct link' -Wait
$null = Set-ADOPSRepository -Project $AzDMProject.Name -RepositoryId $Repo.id -DefaultBranch 'main' 

#endregion

#region Variable group 
# Add a variable group for AzDM settings
$AzDMVariableGroup = @(
    @{Name = 'AzDMOrganizationName'; Value = $AzureDevOpsOrganizationName; IsSecret = $false }
    @{Name = 'AzDMTenantId'; Value = $EntraTenantID; IsSecret = $false }
)
$null = New-ADOPSVariableGroup -Project $AzDMProject.Name -VariableGroupName 'AzDM' -VariableHashtable $AzDMVariableGroup 

#endregion




# Create three new pipelines from existing YAML manifests.
$null = New-ADOPSPipeline -Name 'AzOps - Push'     -YamlPath '.pipelines/push.yml'     -Repository $RepoName @OrgParams
$null = New-ADOPSPipeline -Name 'AzOps - Pull'     -YamlPath '.pipelines/pull.yml'     -Repository $RepoName @OrgParams
$null = New-ADOPSPipeline -Name 'AzOps - Validate' -YamlPath '.pipelines/validate.yml' -Repository $RepoName @OrgParams

# Add build validation policy to validate pull requests
$RepoId = Get-ADOPSRepository -Repository $RepoName @OrgParams | Select-Object -ExpandProperty Id
$PipelineId = Get-ADOPSPipeline -Name 'AzOps - Validate' @OrgParams | Select-Object -ExpandProperty Id
$BuildPolicyParam = @{
    RepositoryId     = $RepoId
    Branch           = 'main'
    PipelineId       = $PipelineId
    Displayname      = 'Validate'
    filenamePatterns = '/root/*'
}
$null = New-ADOPSBuildPolicy @BuildPolicyParam @OrgParams

# Add branch policy to limit merge types to squash only
$null = New-ADOPSMergePolicy -RepositoryId $RepoId -Branch 'main' -allowSquash @OrgParams

# Add pipeline permissions for all three pipelines to the credentials Variable Groups
$Uri = "https://dev.azure.com/$Organization/$ProjectName/_apis/distributedtask/variablegroups?api-version=7.1-preview.2"
$VariableGroups = (Invoke-ADOPSRestMethod -Uri $Uri -Method 'Get').value | Where-Object name -in 'credentials', 'azops'
foreach ($pipeline in 'AzOps - Push', 'AzOps - Pull', 'AzOps - Validate') {
    $PipelineId = Get-ADOPSPipeline -Name $pipeline @OrgParams | Select-Object -ExpandProperty Id
    foreach ($groupId in $VariableGroups.id) {
        $null = Grant-ADOPSPipelinePermission -PipelineId $PipelineId -ResourceType 'VariableGroup' -ResourceId $groupId @OrgParams
    }
}