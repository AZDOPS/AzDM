# Variables
## Azure Variables
$EntraTenantID = '<TODO: SET THIS FIELD>'
$AzureSubsciptionId = '<TODO: SET THIS FIELD>'
$AzureResourceGroupName = '<TODO: SET THIS FIELD>'
$ResourceLocation = '<TODO: SET THIS FIELD>'
$ManagedDevOpsPoolName = '<TODO: SET THIS FIELD>'

## Azure DevOps Variables
$AzureDevOpsOrganizationName = '<TODO: SET THIS FIELD>'
$AzureDevOpsAzDMProject = @{
    Name = '<TODO: SET THIS FIELD>'
    Description = 'AzDM Manager project.'
    ProcessTypeName = 'Basic'
    Visibility = 'Private'
}

# Connect to your Azure DevOps and Azure resources
Connect-AzAccount -Subscription $AzureSubsciptionId -Tenant $EntraTenantID
Connect-ADOPS -Organization $AzureDevOpsOrganizationName -TenantId $EntraTenantID

#region Set up Azure Infrastructure
# This will deploy Managed DevOps pool and related resources - DevCenter with project, VNet, Subnet dedicated to MDP, and User assigned managed identity.
try {
    $RG = Get-AzResourceGroup -Name $AzureResourceGroupName -ErrorAction Stop
} catch {
    $RG = New-AzResourceGroup -Name $AzureResourceGroupName -Location $ResourceLocation
}

$MDPDeploy = New-AzResourceGroupDeployment -Name 'ManagedDevOpsPool' -ResourceGroupName $RG.ResourceGroupName -TemplateFile .\bicepTemplates\main.bicep -TemplateParameterObject @{
    DevCenterName = "${ManagedDevOpsPoolName}DC"
    ManagedIdentityName = "${ManagedDevOpsPoolName}MI"
    subnetNameName = "${ManagedDevOpsPoolName}SN"
    vnetNameName = "${ManagedDevOpsPoolName}VN"
    MDPName = "${ManagedDevOpsPoolName}"
    maximumConcurrency = 1
    ADOUrl = "https://dev.azure.com/$AzureDevOpsOrganizationName"
    MDPImageName = @(
        @{
            wellKnownImageName = 'ubuntu-22.04/latest'
        }
    )
    DevOpsInfrastructurePrincipalId = (Get-AzADServicePrincipal -DisplayName DevOpsInfrastructure).Id
}

#endregion

#region Add managed identity to Azure DevOps
# Add the managed identity to your Azure DevOps organization
$MDPIdentity = $MDPDeploy.Outputs['identity'].Value
$uri = "https://vssps.dev.azure.com/$AzureDevOpsOrganizationName/_apis/graph/serviceprincipals?api-version=7.1-preview.1"
$ClientId = (Get-AzUserAssignedIdentity -Name $MDPIdentity -ResourceGroupName $RG.ResourceGroupName).PrincipalId
$body = "{""originId"": ""$($ClientId)""}"
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
