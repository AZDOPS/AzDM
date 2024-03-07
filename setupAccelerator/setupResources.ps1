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
$AzDMRootFolder = 'Root' # This folder _must_ also be set in settings.json!

# Connect to your Azure DevOps and Azure resources
Connect-AzAccount -Subscription $AzureSubsciptionId -Tenant $EntraTenantID
Connect-ADOPS -Organization $AzureDevOpsOrganizationName -TenantId $EntraTenantID

#region Set up Azure Infrastructure
# Deploy VMSS and network
try {
    $RG = Get-AzResourceGroup -Name $AzureVMSSResourceGroupName -ErrorAction Stop
} catch {
    $RG = New-AzResourceGroup -Name $AzureVMSSResourceGroupName -Location $ResourceLocation
}

$Network = New-AzResourceGroupDeployment -Name 'VMSSNetworkDeploy' -ResourceGroupName $AzureVMSSResourceGroupName -TemplateFile .\bicepTemplates\network.bicep
$VMSS = New-AzResourceGroupDeployment -Name 'VMSSDeploy' -ResourceGroupName $AzureVMSSResourceGroupName -TemplateFile .\bicepTemplates\VMSS.bicep -TemplateParameterObject @{
    adminUserName = $VMSSAdminUserName
    subnetId = $Network.Outputs['subnetId'].Value
    adminPassword = $VMSSAdminPassword
}
#endregion

#region Add managed identity to Azure DevOps
# Add the managed identity to your Azure DevOps organization
$VMSSIdentity = $vmss.Outputs['identity'].Value
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
$AzDMProject = Get-ADOPSProject -Name $AzureDevOpsAzDMProject.Name
if (-not ($AzDMProject)) {
    $AzDMProject = New-ADOPSProject @AzureDevOpsAzDMProject -Wait
}
#endregion

#region Create Azure DevOps pool
## Service connection. We dont have support for automatic idenity creation in ADOPS yet.
$b = @"
{
    "data": {
        "subscriptionId": "$AzureSubsciptionId",
        "subscriptionName": "$((Get-AzSubscription -SubscriptionId $AzureSubsciptionId).Name)",
        "environment": "AzureCloud",
        "scopeLevel": "Subscription",
        "resourceGroupName": "$AzureVMSSResourceGroupName",
        "creationMode": "Automatic"
    },
    "name": "AzDMVMSSServiceConnection",
    "type": "azurerm",
    "url": "https://management.azure.com/",
    "authorization": {
        "parameters": {
            "tenantid": "$EntraTenantID",
            "scope": "$((Get-AzResourceGroup -Name $AzureVMSSResourceGroupName).ResourceId)"
        },
        "scheme": "WorkloadIdentityFederation"
    },
    "isShared": false,
    "isShared": true,
    "owner": "library",
    "serviceEndpointProjectReferences": [
        {
            "projectReference": {
                "id": "$($AzDMProject.id)",
                "name": "$($AzDMProject.name)"
            },
            "name": "AzDMVMSSServiceConnection"
        }
    ]
}
"@

$serviceConnectionuri = "https://dev.azure.com/$AzureDevOpsOrganizationName/$($AzDMProject.name)/_apis/serviceendpoint/endpoints?api-version=7.2-preview.4"
$serviceConnection = Invoke-ADOPSRestMethod -Method Post -Body $b -Uri $serviceConnectionuri

Write-Host "NOTE: Because of stuff and things the creation of a VMSS pool is odd. For now, this step _needs_ to be done manually! Go in to Azure DevOps and set it up by following this guide:"
Write-Host "https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops#create-the-scale-set-agent-pool"
$ElasticPoolName = Read-Host "Enter your pool name, or replace the read-host. I put this here so we wont try the next step without an agent pool created..."

#endregion

#region Create and import the AzDM repository
$Repo = Get-ADOPSRepository -Project $AzDMProject.Name -Repository $AzureDevOpsAzDMRepo
if ($null -eq $Repo) {
    $Repo = New-ADOPSRepository -Project $AzDMProject.Name -Name $AzureDevOpsAzDMRepo 
}

# Import the AzDM repo
$repoImport = Import-ADOPSRepository -Project $AzDMProject.Name -RepositoryName $Repo.name -GitSource 'https://github.com/AZDOPS/AzDMTemplate.git' -Wait
$setMain = Set-ADOPSRepository -Project $AzDMProject.Name -RepositoryId $Repo.id -DefaultBranch 'main' 

#endregion

#region Variable group 
# Add a variable group for AzDM settings
$AzDMVariableGroup = @(
    @{Name = 'AzDMOrganizationName'; Value = $AzureDevOpsOrganizationName; IsSecret = $false }
    @{Name = 'AzDMTenantId'; Value = $EntraTenantID; IsSecret = $false }
)
$null = New-ADOPSVariableGroup -Project $AzDMProject.Name -VariableGroupName 'AzDM' -VariableHashtable $AzDMVariableGroup 
#endregion

#region create new pipelines from existing YAML manifests.
$PushPipeline = New-ADOPSPipeline -Name 'AzDM - Push' -YamlPath '.pipelines/Push.yaml' -Repository $Repo.name -Project $AzDMProject.Name
$ValidatePipeline = New-ADOPSPipeline -Name 'AzDm - Validate' -YamlPath '.pipelines/Validate.yaml' -Repository $Repo.name -Project $AzDMProject.Name
#endregion

#region add build validation policy to validate pull requests
$BuildPolicyParam = @{
    RepositoryId     = $Repo.id
    Branch           = 'main'
    PipelineId       = $ValidatePipeline.id
    Displayname      = 'Validate'
    filenamePatterns = "/$AzDMRootFolder/*"
}
$null = New-ADOPSBuildPolicy @BuildPolicyParam -Project $AzDMProject.Name

# Add branch policy to limit merge types to squash only
$null = New-ADOPSMergePolicy -RepositoryId $Repo.id -Branch 'main' -allowSquash -Project $AzDMProject.Name

# Add pipeline permissions for all three pipelines to the credentials Variable Groups
$VariableGroupUri = "https://dev.azure.com/$AzureDevOpsOrganizationName/$($AzDMProject.name)/_apis/distributedtask/variablegroups?api-version=7.1-preview.2"
$VariableGroups = (Invoke-ADOPSRestMethod -Uri $VariableGroupUri -Method 'Get').value | Where-Object -Property 'name' -eq 'AzDM'
foreach ($pipeline in 'AzDM - Push', 'AzDM - Validate') {
    $PipelineId = Get-ADOPSPipeline -Name $pipeline -Project $AzDMProject.Name | Select-Object -ExpandProperty Id
    foreach ($groupId in $VariableGroups.id) {
        $null = Grant-ADOPSPipelinePermission -PipelineId $PipelineId -ResourceType 'VariableGroup' -ResourceId $groupId  -Project $AzDMProject.Name
    }
}

#region Grant pipelines access to VMSS pool and service connection
$b = @"
{
    "pipelines": [
        {
            "id": $($ValidatePipeline.id),
            "authorized": true
        },
        {
            "authorized": true,
            "id": $($PushPipeline.id)
        }
    ]
}
"@

### VMSS
$queueId = (Invoke-ADOPSRestMethod "https://dev.azure.com/$AzureDevOpsOrganizationName/$($AzDMProject.name)/_apis/distributedtask/queues?queueNames=$($ElasticPoolName)&api-version=7.2-preview.1").value.id
$queueUri = "https://dev.azure.com/$AzureDevOpsOrganizationName/$($AzDMProject.name)/_apis/pipelines/pipelinePermissions/queue/${queueId}?api-version=7.2-preview.1"
Invoke-ADOPSRestMethod -Method Patch -Uri $queueUri -Body $b
### Service connection
$enpointUri = "https://dev.azure.com/$AzureDevOpsOrganizationName/$($AzDMProject.name)/_apis/pipelines/pipelinePermissions/endpoint/$($serviceConnection.id)?api-version=7.2-preview.1"
Invoke-ADOPSRestMethod -Method Patch -Uri $enpointUri -Body $b

#endregion

