<#
.SYNOPSIS
    Gets the supported settings values of a project, repo, and pipeline.
.DESCRIPTION
    This function gets the supported settings values of a project, repo, and pipeline in any AzDM json file.
    the settings are fetched from the AzDM documentation repo from one of the following locations:
    https://raw.githubusercontent.com/AZDOPS/AzDM/main/documentation/project.md
    https://raw.githubusercontent.com/AZDOPS/AzDM/main/documentation/pipelines.md
    https://raw.githubusercontent.com/AZDOPS/AzDM/main/documentation/repos.md
    and as such the layout of these documentation files needs to be correct and you need online access for this function to work.
.NOTES
    Requires internet access
.LINK
    https://github.com/AZDOPS/AzDM/blob/main/documentation
.EXAMPLE
    Get-AzDMSupportedSettings -SettingsLevel Repo
    This command returns the valid settings for a repository.
#>

Param(
    [ValidateSet('Project','Pipeline','Repo','Artifacts')]
    $SettingLevel
)

switch ($SettingLevel) {
    'Project' { $rawData = Invoke-RestMethod 'https://raw.githubusercontent.com/AZDOPS/AzDM/main/documentation/project.md' }
    'Pipeline' { $rawData = Invoke-RestMethod 'https://raw.githubusercontent.com/AZDOPS/AzDM/main/documentation/pipelines.md' }
    'Repo' { $rawData = Invoke-RestMethod 'https://raw.githubusercontent.com/AZDOPS/AzDM/main/documentation/repos.md' }
    'Artifacts' { $rawData = Invoke-RestMethod 'https://raw.githubusercontent.com/AZDOPS/AzDM/main/documentation/artifacts.md' }
}

# Split on the header "## Supported <whatever> settings", and everything up to the next header. Split on newlines to make sure it is a string array
$rawData = ($rawData -split '## Supported.*settings')[1].Split('##')[0].split("`n")
# Regex matches anything that starts with a '|' and ends with a '|'. Result is the settings table
$rawData = $rawData.Where({$_ -match '^\|'}) -replace '^\|\s+([^\s]+).*\|$','$1'
# The first two lines are the header and the separator of the table. Ignore those.
$rawData[2..($rawData.Count -1)]
