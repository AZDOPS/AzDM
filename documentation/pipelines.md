# pipelines

## File list

The following files _may_ take effect when setting up a pipeline and will be set in falling order

- /Root/config.json
- /Root/projectName/projectName.json
- /Root/projectName/pipelines/projectName.pipelines.json
- /Root/projectName/pipelines/pipelineName/pipelineName.json

## Supported pipelines settings.

The following table shows if a value is required, and if it has a default setting.
Required values are values that _can not be calculated_ and needs to be set somewhere.
A required value may be set in any or all of the files above.

| Setting | Required | default value |
| --- | --- | --- |
| Name | true | |
| FolderPath | false | defaults to '/' |
| Repository | true | |
| YamlPath | false | defaults to './azure-pipelines.yml' |
| Project | false | calculated from file location |
| QueueStatus | false | enabled |

## Pipeline placeholder values

In order to easier configure pipeline defaults per project I created a few placeholder values.

In the file `projectName.pipelines.json` you may add the value `{{pipeline.name}}` to set the same value as the pipeline name. For example, this json setting would make all _non overridden_ pipelines have the name set in pipelines.names, and it will look for a repo with the same name where the yaml file will be created.

```Json
"defaults": {
    "Name": "{{pipeline.name}}",
    "Repository": "{{pipeline.name}}"
}
```
