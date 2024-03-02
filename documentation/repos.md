# repos

## File list

The following files _may_ take effect when setting up a repo and will be set in falling order

- /Root/config.json
- /Root/projectName/projectName.json
- /Root/projectName/repos/projectName.repos.json
- /Root/projectName/repos/repoName/repoName.json

## Supported repo settings.

The following table shows if a value is required, and if it has a default setting.
Required values are values that _can not be calculated_ and needs to be set somewhere.
A required value may be set in any or all of the files above.

| Setting | Required | default value |
| --- | --- | --- |
| Name | true | |
| DefaultBranch | false | defaults to 'main' |
| IsDisabled | false | defaults to '$false' |
| Project | false | calculated from file location |
