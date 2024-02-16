# AzDM
Azure DevOps Manager.

## Stage 1 requirements

- [x] Folder structure 
- [ ] Supported settings list
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
- [ ] Data/Settings merging
    - [ ] Bind to root folder - Something better than $PSScriptRoot to know where the root structure is.
    - [ ] format of data?
        - [ ] casing of properties in config files?
    - [ ] Basic data content?
- [x] Automated deploy pipeline
    - [ ] TODO: Base createYamlFromTemplateFile in pipelines.ps1 on ADOPS function
- [ ] Automated verify / WhatIf pipeline
- [x] Deploying projects
- [x] Deploying pipelines
    - [ ] Improve yaml template management in pipelines functions - Allow for different yaml templates?
- [x] Deploying repos
- [ ] Deploying artifact feeds
- [ ] TODO: Updating projects
    - [x] Requirement: git diff in pipeline to verify what is changed
    - [ ] ADOPS - Set-ADOPSProject - https://learn.microsoft.com/en-us/rest/api/azure/devops/core/projects/update?view=azure-devops-rest-7.2
- [x] Updating pipelines
    - [ ] Convert some code to ADOPS functions - Get-ADOPSBuildDefinition, Set-ADOPSBuildDefinition
    - [x] Requirement: git diff in pipeline to verify what is changed
- [x] Updating repos
    - [x] Requirement: git diff in pipeline to verify what is changed
- [ ] Adding members (AD Accounts) to built in project groups
    - [ ] Merge access with existing (add only)
- [ ] Dependencies
    - [ ] VMSS Bicep setup w. managed identity
    - [ ] Service connection
    - [ ] Library - task settings for pipeline
        - [ ] 'AzDM' - 'AzDMOrganizationName'
        - [ ] 'AzDM' - 'AzDMTenantId'
    - [ ] PowerShell functions to create json templates - Make sure the format of all level json is correct including casing.
- [ ] QuickStart templates (import all required setup)

## Stage 2 requirements

- [ ] Pull existing data
- [ ] policy mismatch report
- [ ] Extended security and access
    - [ ] Merge false - Overwrite default access