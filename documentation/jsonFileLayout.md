# File layout of all json files

  * [About](#About)
  * [settings.json](#settingsjson)
  * [config.json](#configjson)
  * [projectName.json](#projectnamejson)
  * [projectName.repos.json](#projectNamereposjson)
  * [projectName.pipelines.json](#projectNamepipelinesjson)
  * [repoName.json](#repoNamejson)
  * [pipelineName.json](#pipelineNamejson)

## About

Because there are _a lot_ of json files involved in this project I decided to document them here. If a json file is missing, please open an issue, or create a pull request to improve documentation.

> **Important:** In many cases the usage of these files are case sensitive and _will not work_ if capitalization is not as documented. Fore example `"Repos": {}` and `"repos": {}` are different. If you have issues, please verify the capitalization before opening an issue!

## settings.json

Structure location: Root of your repo.
Name: settings.json
Note: This file should only contain AzDM configurations.

```json
{
    "azdm_core": {
      "rootfolder": "Root" // required. Where project folders are created
    }
}
```

## config.json

Structure location: Root folder set in settings.json.
Name: config.json
Note: This file contains _global_ organization wide settings, as well as configuration settings applied for all projects.

```json
{
    "core": {
      "excludeProjects": [ "projectName1","projectName2" ] // Array of project folders to exclude from management.
    },
    "organization": { // Any settings here will be applied to _all_ projects unless overwritten in configurations further down in the hierarchy. Supported settings are documented in each separate chapter.
        "security": { },
        "project": { },
        "repos": { },
        "pipelines": { }
    }
}

```

## projectName.json

Structure location: Root of a project.
Name: Same as project. 
Note: Capitalization of the file name and the folder name _must_ be the same.

```json
{
    "core": {
      "reposFolder": "<subfolder where repos are located>", // Required!! For repos functionality
      "pipelinesFolder": "<subfolder where repos are located>" // Required!! For pipelines functionality
    },
    "defaults": {
        "Description": "<Project description>", // not required 
        "ProcessTypeName": "<Project process, f.eg Scrum or Basic>" // required if not set as default setting
    },
    "project": { // the project key _needs_ to exist in order for any repos, pipelines, or security to be applied. 
        // Any settings here will be applied to this project unless overwritten in configurations further down in the hierarchy. Supported settings are documented in each separate chapter.
        "security": { },
        "repos": { },
        "pipelines": { }
    }
}
```

## projectName.repos.json

Structure location: root/projectName/repos/
Name: projectName.repos.json
Note: Capitalization of the file name and the path _must_ be the same.

```json
{
    "repos.names": [ "repo1","repo2" ], // Required! Any string here will create a repo with this name
    "defaults": { } // Overrides global default settings for repositories for _all_ repos in this project.
}

```

## projectName.pipelines.json

Structure location: root/projectName/pipelines/
Name: projectName.pipelines.json
Note: Capitalization of the file name and the path _must_ be the same.
Note: I have implemented some place holder functionality in order to set defaults easier. Please see [pipelines](pipelines.md) for details

```json
{
    "pipelines.names": [ "pipeline1","pipeline2" ],  // Required! Any string here will create a pipeline with this name
    "defaults": { } // Overrides global default settings for pipelines for _all_ repos in this project.
}

```

## repoName.json

Structure location: root/projectName/pipelines/repoName/
Name: repoName.json
Note: Capitalization of the file name and the path _must_ be the same.

```json
{ } // This list may contain all settings supported by repos
```

## pipelineName.json

Structure location: root/projectName/pipelines/pipelineName/
Name: pipelineName.json
Note: Capitalization of the file name and the path _must_ be the same.

```json
{ } // This list may contain all settings supported by pipelines
```
