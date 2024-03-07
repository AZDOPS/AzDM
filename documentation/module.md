# AzDM module

The AzDM module is the core functionality and where 99% of the magic happens.

It is based on the structure and usage of the [ADOPS](https://github.com/AZDOPS/AZDOPS/) module and the base idea is that every piece of functionality in AzDM _should_ be included or built on a ADOPS function.

This also means that you can in most cases use AzDM _outside_ of a pipeline, simply by making sure the ADOPS module is installed, and you have connected to your Azure DevOps organization using `Connect-ADOPS` before importing the AzDM module using `Import-Module .\.module\AzDM.psm1`.

AzDM is an ugly module and this is on purpose.

It does not follow proper Verb-Noun naming standards, it does not separate functionality on a per function basis, It doesn't have a manifest, and it does not include Get-Help docs. 

The main reason for this is that the primary use case for AzDM is not as a locally run module but as a tool in the pipeline.

## Finding and installing the module.

If you do not use the [setup accelerator scripts](../setupAccelerator/readme.md), or if you want to update the module, the best place to go is the [template repo](https://github.com/AZDOPS/AzDMTemplate/)

Updates are made by replacing the `.module` and any other folders except your root folder from the repo.

You may see which version of the module you are running by looking in the `AzDM.psm1` file.

## Global variables

AzDM sets a number of global variables that it needs to use when creating and / or updating any functionality.
These global variables also contains the baseline of supported settings for their respective objects.

In order to get all global variables you may run the following code:

```PowerShell
Import-Module .\.module\AzDM.psm1
Get-Variable AzDM*
```

## Baseline settings

Some global variables contains the baseline settings for a specific object.
For example, the variable `$Global:AZDMPipelineSettings` may contain the following keys:

```Text
Name
FolderPath
Repository
YamlPath
Project
FileList
QueueStatus
```

As such, these are the keys / values you can currently configure using AzDM for pipelines _with one exception_.

### FileList

FileList is a special key set on all configurable objects related to changes, such as projects, pipelines, and repos.
In order to keep track of changes and what is updated this list contains all files that may affect one specific object.

Therefore I suggest you do not set this property somewhere as it will cause issues with git and change integration.

## Function structure and functionality

Functions are structured around areas of functionality. If a function is specific for repos, it is located in the `repos.ps1` file, if a function is specific for projects, it is located in the `projects.ps1` file, and so on.

Every functionality file _must_ contain some specific parts in order to work correctly:

- mergeFunctionalitySetting
    - For example: `mergePipelineSetting`
    - This function goes through the file tree and builds the result object for _one specific resource_. The resulting object is used for creating, comparing, and updating any part of this object.
- createFunctionality
    - For example: `createPipeline`
    - This function creates a new resource. In some cases creating a new resource also requires an update. For example if a specific setting can't be set while creating, but needs to be updated. If so, it should also be done here.
- updateFunctionality
    - For example: `updatePipeline`
    - This function updates the resource by comparing an existing object with the merged setting and performs any needed changes.
- diffCheckFunctionality
    - For example: `diffCheckPipeline`
    - This function compares an existing object with an AzDM configuration and outputs any differences in a standard format. This format is used to update any existing object _and_ outputting changes to a verify pipeline.

## Adding functionality

If you want to add functionality to an object, or add an entirely new type of object, you need to update a number of places:

- Global variables. These are set in the file AzDM.ps1, and contains the base objects. If a setting isn't defined here it will not be included in the create / update object.
- functionalityFiles.ps1. Most settings will be read correctly and included from the base object, but for example diffCheckFunctionality contains a number of exclusions and special cases and may need to be updated.
- ADOPS module. Since this is the module we use to set everything up we will require the functionality to be included there as well.

## Debugging

All module functions should support the standard verbose, error, and debug message output, which makes it fairly easy to debug. Simply enable all message streams in your pipeline yaml by adding the following to your tasks

```Yaml
verbosePreference: 'continue'
debugPreference: 'continue'
```

You may also debug your setup locally by cloning your repo and running any code locally.
