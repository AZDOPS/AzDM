<#
.SYNOPSIS
    Gets the file layout of a json file and outputs it to file.
.DESCRIPTION
    This function gets the complete layout, including help text, for a AzDM json file.
    The filenames and contents are fetched from https://github.com/AZDOPS/AzDM/blob/main/documentation/jsonFileLayout.md,
    and as such the layout of this documentation file needs to be correct and you need online access for this function to work.
.NOTES
    Requires internet access
.LINK
    https://github.com/AZDOPS/AzDM/blob/main/documentation/jsonFileLayout.md
.EXAMPLE
    New-AzDMJsonFile -Location ./Root/Westeros/config.json -JsonType config.json
    This command will create a config.json file with supported values for a project configuration,
    located in the relative path ./Root/Westeros/
#>

param(
    $Location,
    
    [ValidateSet('settings.json','config.json','projectName.json','projectName.repos.json','repoName.json','projectName.pipelines.json','pipelineName.json')]
    $JsonType
)

$jsonDocsContent = Invoke-RestMethod 'https://raw.githubusercontent.com/AZDOPS/AzDM/main/documentation/jsonFileLayout.md'
$resJson = ($jsonDocsContent.Split("## $jsonType")[1]).Split("##")[0]
$resJson = $resJson.Split('```json')[1].Split('```')[0].Trim()

if (Test-Path $Location) {
    Write-Error "File $Location already exists. Remove it, or pick a new location."
}
else {
    $resJson | Out-File $Location
}
