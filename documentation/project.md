# projects

## File list

The following files _may_ take effect when setting up a project and will be set in falling order

- /Root/config.json
- /Root/projectName/projectName.json

## Supported project settings.

The following table shows if a value is required, and if it has a default setting.
Required values are values that _can not be calculated_ and needs to be set somewhere.
A required value may be set in any or all of the files above.

| Setting | Required | default value |
| --- | --- | --- |
| Name | true | |
| Description | false | |
| Visibility | false | defaults to 'Private' |
| ProcessTypeName | false | defaults to 'Basic' |
| SourceControlType | false | defaults to 'Git' |
