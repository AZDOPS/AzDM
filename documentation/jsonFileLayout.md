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

> **Important:** In many cases the usage of these files are case sensitive and _will not work_ if capitalization is not as documented. For example `"Repos": {}` and `"repos": {}` are different. The same is also valid for file and folder names. Capitalization of the filename and the folder name _must always_ be the same. Non consistent capitalization may lead to failures. **If you have issues, please verify the capitalization before opening an issue!**

Every property covered in any json config _should_ be in camelCase!

## settings.json

- Structure location: Root of your repo.
- Name: settings.json
- Note: This file should only contain AzDM configurations.

```json
{
    "azdm_core": {
      "rootfolder": "Root" // required. Where project folders are created
    }
}
```

## config.json

- Structure location: Root folder set in settings.json.
- Name: config.json
- Note: This file contains _global_ organization wide settings, as well as configuration settings applied for all projects.

```json
{
    "core": {
      "excludeProjects": [ "projectName1","projectName2" ] // Array of project folders to exclude from management.
    },
    "organization": { // Any settings here will be applied to _all_ projects unless overwritten in configurations further down in the hierarchy. Supported settings are documented in each separate chapter.
        "security": { },
        "project": { },
        "repos": { },
        "pipelines": { },
        "artifacts": { }
    }
}

```

## projectName.json

- Structure location: Root of a project.
- Name: projectName.json 

```json
{
    "core": {
      "reposFolder": "<subfolder where repos are located>", // Required!! For repos functionality
      "pipelinesFolder": "<subfolder where pipelines are located>", // Required!! For pipelines functionality
      "artifactsFolder": "<subfolder where repos are located>" // Required!! For artifacts functionality
    },
    "defaults": {
        "description": "<Project description>", // not required 
        "processTypeName": "<Project process, f.eg Scrum or Basic>" // required if not set as default setting
    },
    "project": { // the project key _needs_ to exist in order for any repos, pipelines, or security to be applied. 
        // Any settings here will be applied to this project unless overwritten in configurations further down in the hierarchy. Supported settings are documented in each separate chapter.
        "security": { },
        "repos": { },
        "pipelines": { },
        "artifacts": { }
    }
}
```

## projectName.repos.json

- Structure location: root/projectName/repos/
- Name: projectName.repos.json

```json
{
    "repos.names": [ "repo1","repo2" ], // Required! Any string here will create a repo with this name
    "defaults": { } // Overrides global default settings for repositories for _all_ repos in this project.
}

```

## projectName.pipelines.json

- Structure location: root/projectName/pipelines/
- Name: projectName.pipelines.json

```json
{
    "pipelines.names": [ "pipeline1","pipeline2" ],  // Required! Any string here will create a pipeline with this name
    "defaults": { } // Overrides global default settings for pipelines for _all_ repos in this project.
}

```

## projectName.artifacts.json

- Structure location: root/projectName/artifacts/
- Name: projectName.artifacts.json

```json
{
    "artifacts.names": [ "feed1","feed2" ], // Required! Any string here will create a feed with this name
    "defaults": { } // Overrides global default settings for artifacts for _all_ feeds in this project.
}

```

## repoName.json

- Structure location: root/projectName/repos/repoName/
- Name: repoName.json

```json
{ } // This list may contain all settings supported by repos
```

## pipelineName.json

- Structure location: root/projectName/pipelines/pipelineName/
- Name: pipelineName.json

```json
{ } // This list may contain all settings supported by pipelines
```

## artifactsName.json

- Structure location: root/projectName/artifacts/artifactsName/
- Name: artifactsName.json

```json
{ } // This list may contain all settings supported by repos
```
