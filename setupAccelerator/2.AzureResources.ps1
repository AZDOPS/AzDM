# Variables
## Azure Variables
$EntraTenantID = '<TODO: SET THIS FIELD>'
$AzureSubsciptionId = '<TODO: SET THIS FIELD>'
$AzureVMSSResourceGroupName = '<TODO: SET THIS FIELD>'
$ResourceLocation = '<TODO: SET THIS FIELD>'
$VMSSAdminUserName = '<TODO: SET THIS FIELD>'
$VMSSAdminPassword = New-YapgPassword -AddChars -Capitalize -Leet

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
