# AzDM
Azure DevOps Manager.

## Stage 1 requirements

- [x] Folder structure 
- [ ] Supported settings list
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
- [ ] Automated deploy pipeline
- [ ] Automated verify / WhatIf pipeline
- [ ] Deploying projects
- [ ] Deploying pipelines
- [ ] Deploying repos
- [ ] Deploying artifact feeds
- [ ] Updating projects
- [ ] Updating pipelines
- [ ] Updating repos
- [ ] Adding members (AD Accounts) to built in project groups
    - [ ] Merge access with existing (add only)
- [ ] Dependencies
    - [ ] VMSS Bicep setup w. managed identity
    - [ ] Service connection
- [ ] QuickStart templates (import all required setup)

## Stage 2 requirements

- [ ] Pull existing data
- [ ] policy mismatch report
- [ ] Extended security and access
    - [ ] Merge false - Overwrite default access