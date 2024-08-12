# AzDM
Azure DevOps Manager.

## Stage 2 requirements

- [ ] Move all of this todo stuff to GitHub and use a board of some kind instead..
- [ ] Pull existing data
- [ ] policy mismatch report
  - [ ] Extend reporting to
    - [ ] Extensions
    - [ ] Full security list
- [ ] Extended security and access
    - [ ] Merge false - Overwrite default access
    - [ ] Add new Teams and update old ones with members
- [ ] Improve yaml template management in pipelines functions - Allow for different yaml templates?
- [ ] YAML template features as demo
    - [ ] Keyvault references in library
    - [ ] approval steps / locked resources / Environments
- [ ] Adding custom process templates
    - [ ] "Create a copy of template x and add to project"
- [ ] Queries for boards using templates
    - [ ] Have library of queries and map them in to projects
- [x] Base createYamlFromTemplateFile in pipelines.ps1 on ADOPS function
    - [X] Create ADOPS function
- [ ] Clarify release procedure
    - [ ] Synchronize AzDM and AzDMTemplate release
    - [ ] Set up release pipeline
        - [ ] Set module version in PSM1 according to [design.md](./documentation/design.md)