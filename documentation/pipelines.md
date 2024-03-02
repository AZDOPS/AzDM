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
