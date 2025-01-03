# Setup accelerator

This folder contains tools and scripts that can help you get up and running in no time.

> **Important!** Never run unknown code from the internet, not even this one. Before running the code included in this folder make sure you understand what it does, and you know what the results will be.

> Note: Some tasks are still manual. They may be automated at some time, but for now, sorry.

All scripts require editing to set variables before being run. If you do not set these before running it _will not work_.
The local .gitignore file is configured to ignore `*.local.*`, which means if you save your config files as `2.AzureResources.local.ps1` it will not be included in git, and you can safely keep your config without risk pushing it to a repo.

## Running order 

1. `1.prereqs.ps1`
    - This script installs any modules needed for the rest of the code.
2. `2.AzureResources.ps1`
    - Creates Resource group
    - Deploys network and subnet using Bicep
    - Deploys managed identity using Bicep
    - Deploys DevCenter and project using Bicep
    - Deploys Managed DevOps pool (MDP) using Bicep
    - Adds the MDP managed identity to Azure DevOps, assigns a basic license, and adds it to the 'Project collection administrators' group
    - Creates the Azure DevOps project
3. `3.AzDOResources.ps1`
    - Creates the AzDM repo
    - Imports the [AzDM Template repo](https://github.com/AZDOPS/AzDMTemplate)
    - Creates the needed variable group
    - Creates the pipeline definitions for `AzDM - Push` and `AzDM - Validate`
    - Sets repo validation policy
    - Sets repo merge policy
    - Adds pipeline permissions for variable group 
    - Adds pipeline permissions for Managed DevOps pool
4. **Manual step**
    - Update `Push.yaml`, value `Pool:` with the configured name of your Managed DevOps pool
    - Update `Validate.yaml`, value `Pool:` with the configured name of your Managed DevOps pool
    - If `$AzDMRootFolder` in 3, `3.AzDOResources.ps1`, is _not_ `Root`
        - In your repository, create the new folder
        - create or copy `config.json` from `/Root/` to your new root folder
        - Verify the value of `rootfolder:` in `settings.json` is pointing to your new root folder.
        - Update the path filter in `Push.yaml`
        - Update the path filter in Build validation for your repo
            - Project settings -> Repositories -> Repo name -> Policies -> Branch policies -> Main branch -> Build validation -> Path filter
