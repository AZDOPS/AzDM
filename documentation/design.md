# Design decisions.

I _try_ to follow these rules to the best I can. If you find somewhere I have failed, please let me know by creating an issue.

In no particular order:

- All settings in json files shall be in camelCase with the following exceptions
    - Names, such as project, repo, pipeline, and group names, shall use the casing needed.
    - Parameter value names - Settings for for example projects, repos, and pipelines, that will be used as parameters to ADOPS functions shall use the same casing as the parameters.
- All PowerShell functions should be named in camelCase with the following exceptions
    - Invoke-AzDM - Called from the pipeline yaml.
- Internal variables use camelCase
- Parameter variables use PascalCase
- All functions, internal and external, shall have the CmdLetBinding attribute in order to properly support -Verbose, -Debug and other streams.
- All PowerShell module functions exist inside a file with a name matching the functionality
