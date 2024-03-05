# Requirements.

  * [Required resources](#Requiredresources)
    * [VMSS Agents](#VMSSAgents)
    * [Azure DevOps setup](#AzureDevOpssetup)
    * [Azure DevOps project](#AzureDevOpsproject)
    * [Agent pool](#Agentpool)
    * [Repository](#Repository)
    * [Pipelines and variable group](#Pipelinesandvariablegroup)
    * [Build policies](#Buildpolicies)


## Required resources

The following resources are needed to run AzDM.

You may also use the [AzDM accelerator scripts](../../setupAccelerator/readme.md) to quickly get up and running.

### VMSS Agents
- An Azure subscription where agents will be placed
    - Connected to a network. No internal network access is needed for AzDM to work.
    - A User account with _at least_ contribution access to this Azure Subscription to create said resources
- Azure VNet and Subnet
- VMSS Connected to the subnet
    - This VMSS may run any operating system, but PowerShell is required. If PowerShell isn't installed in your image it will be installed during run.

### Azure DevOps setup
- Import the managed identity from your VMSS to Azure DevOps by following [this guide.](https://learn.microsoft.com/azure/devops/integrate/get-started/authentication/service-principal-managed-identity?view=azure-devops#2-add-and-manage-service-principals-in-an-azure-devops-organization)
- The manged identity will need to be granted at least a `Basic` license.
- Add the managed identity to the `[AzureDevOpsOrganization]\Project Collection Administrators` group
    - This is required in order for AzDM to manage all levels of your Azure DevOps organization.

### Azure DevOps project
- An Azure DevOps project. This project may be shared with other resources, but since AzDM requires high privilege this is _**absolutely not recommended!**_

### Agent pool
- A service connection from Azure DevOps to the resource group where your VMSS was created.
    - This service connection needs at least the `Virtual Machine Contributor` role to scale images.
- Using this service connection create an agent pool in Azure DevOps
    - After the [pipelines](#Pipelinesandvariablegroup) are created, grant all pipelines access to this agent pool

### Repository
- A repository for the AzDM module and related files
    - These files can be imported from our quick start repo, or downloaded and copied. We currently do not have any way of deploying the AzDM module automatically.

### Pipelines and variable group
> **Important** The variable group _must_ be created before the pipelines or things may go wrong!

- One variable group named `AzDM`
    - Variables:
        - AzDMOrganizationName: `the organization AzDM should manage. Most commonly your own Azure DevOps organization`
        - AzDMTenantId: `Entra ID tennant where your managed identity resides`
- One Push pipeline created from the `.pipelines/Push.yaml` file
    - After creation, edit the pipeline yaml file to use your VMSS pool: `pool: AzDM-VMSS`
- One Push pipeline created from the `.pipelines/Validate.yaml` file
    - After creation, edit the pipeline yaml file to use your VMSS pool: `pool: AzDM-VMSS`
- Grant _both_ pipelines access to the variable group

### Build policies
- Add build validation setting for branch `main` to run the `Validate` pipeline on pull request
    - Add Path filter for your configured `root` folder. see [this json](../jsonFileLayout.md#settingsjson)
- Enable the `Limit merge types` setting and _only_ select `Squash merge`
