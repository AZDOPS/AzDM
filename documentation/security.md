# Security

## File list

The following files _may_ take effect when adding or updating security

- /Root/config.json
- /Root/projectName/projectName.json

## Supported security settings.

Security settings is a bit different from other objects in AzDM and currently only works with built in roles.
You may add a user to any role in a project by adding the following key in any of the supported levels

```Json
"security": {
    "mergeAccess": true,
    "permissions": { }
}
```

## permissions

This list shall be set with any requested _group name_ as key, containing a _string array_ of users as value.

Group name is any of the _existing_ groups in a project, without any project tags. For example:

> - The project name is "myProject" and the group is "Contributors".
> - The groups _principal name_ is "\[myProject]\Contributors"
> - The _key_ shall be "Contributors"

Because of how Azure DevOps treats users you _must_ use a users **principalName** as value. If the user is an Entra ID user the most common principalName is the users email address.

> Note: You may use the [ADOPS](https://github.com/AZDOPS/AZDOPS/) module to find user principal names.
>
>  `Get-ADOPSUser -Name "user" | Select-Object -Property displayName, principalName`

The resulting json should look like this:

```json
"security": {
    "mergeAccess": true,
    "permissions": {
        "Project Administrators": [
            "adminUser1@nomail.address"
        ],
        "Contributors": [
            "codeMonkey1@nomail.address"
        ]
    }
}
```

## mergeAccess

Currently this key is not implemented and will not do anything, but in a future update we will add functionality to set this to `false` and override a group entirely and remove any user not in this list, or `true` to only add the following members ignoring any other changes.
