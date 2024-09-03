# Variables
## Azure Variables
$EntraTenantID = '<TODO: SET THIS FIELD>'
$AzureSubsciptionId = '<TODO: SET THIS FIELD>'

## Azure DevOps Variables
$AzureDevOpsOrganizationName = '<TODO: SET THIS FIELD>'
$AzureDevOpsAzDMProject = @{
    Name = '<TODO: SET THIS FIELD>'
    Description = 'AzDM Manager project.'
    ProcessTypeName = 'Basic'
    Visibility = 'Private'
}
$AzureDevOpsAzDMRepo = '<TODO: SET THIS FIELD>'
$AzDMRootFolder = '<TODO: SET THIS FIELD>' # This folder _must_ also be set in settings.json!
$ManagedDevOpsPoolName = '<TODO: SET THIS FIELD>' # This should be set to the name of your Managed DevOps pool from step 2.

# Connect to your Azure DevOps and Azure resources
Connect-AzAccount -Subscription $AzureSubsciptionId -Tenant $EntraTenantID
Connect-ADOPS -Organization $AzureDevOpsOrganizationName -TenantId $EntraTenantID

$AzDMProject = Get-ADOPSProject -Name $AzureDevOpsAzDMProject.Name

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

#region Grant pipelines access to Managed DevOps pool
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

### Managed DevOps Pool
$queueId = (Invoke-ADOPSRestMethod "https://dev.azure.com/$AzureDevOpsOrganizationName/$($AzDMProject.name)/_apis/distributedtask/queues?queueNames=$($ManagedDevOpsPoolName)&api-version=7.2-preview.1").value.id
$queueUri = "https://dev.azure.com/$AzureDevOpsOrganizationName/$($AzDMProject.name)/_apis/pipelines/pipelinePermissions/queue/${queueId}?api-version=7.2-preview.1"
Invoke-ADOPSRestMethod -Method Patch -Uri $queueUri -Body $b

#endregion

