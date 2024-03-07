# AzDM
Azure DevOps Manager.

## Stage 1 requirements

- [x] Folder structure 
- [x] Supported settings list
    - [x] Static values - Values needed for runtime
        - Project
        - Organization
    - [x] Project
        - Name
        - Description
        - Visibility
        - ProcessTypeName
        - SourceControlType
    - [x] repos
        - Name
        - DefaultBranch
        - IsDisabled
    - [x] pipelines
        - FolderPath
        - Name
        - Repository
        - YamlPath
- [x] Data/Settings merging
    - [x] Bind to root folder - Something better than $PSScriptRoot to know where the root structure is.
    - [x] format of data?
- [x] Automated deploy pipeline
    - [ ] Base createYamlFromTemplateFile in pipelines.ps1 on ADOPS function
- [x] Deploying projects
- [x] Deploying pipelines
- [x] Deploying repos
- [ ] Deploying artifact feeds
- [x] Updating projects
    - [x] Requirement: git diff in pipeline to verify what is changed
    - [x] ADOPS - Set-ADOPSProject - https://learn.microsoft.com/en-us/rest/api/azure/devops/core/projects/update?view=azure-devops-rest-7.2
- [x] Updating pipelines
    - [x] Convert some code to ADOPS functions - Get-ADOPSBuildDefinition, Set-ADOPSBuildDefinition
    - [x] Requirement: git diff in pipeline to verify what is changed
- [x] Updating repos
    - [x] Requirement: git diff in pipeline to verify what is changed
- [x] Adding members (AD Accounts) to built in project groups
    - [x] Merge access with existing (add only) 
- [x] Automated verify / WhatIf pipeline
- [ ] Dependencies
    - [x] VMSS Bicep setup w. managed identity
    - [x] Service connection
    - [x] Library - task settings for pipeline
        - [x] 'AzDM' - 'AzDMOrganizationName'
        - [x] 'AzDM' - 'AzDMTenantId'
    - [ ] PowerShell functions to create json templates - Make sure the format of all level json is correct including casing.
- [x] QuickStart templates (import all required setup)
- [x] Documentation!!
    - [x] a _real_ readme.md...
    - [x] casing of properties in config files
    - [x] All levels JSON layout and valid keys
        - [x] Security needs principalName - usually email for Entra ID users.
    - [x] Module concept - Global settings and how functions use them


## Stage 2 requirements

- [ ] Pull existing data
- [ ] policy mismatch report
- [ ] Extended security and access
    - [ ] Merge false - Overwrite default access
- [ ] Improve yaml template management in pipelines functions - Allow for different yaml templates?