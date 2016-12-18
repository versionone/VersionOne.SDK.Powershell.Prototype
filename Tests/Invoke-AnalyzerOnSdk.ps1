<#
Run the script analyzer on all the code
#>
if ( -not ( Get-Module PSScriptAnalyzer))
{
    throw "Analyzer not found.  As Admin, run:  Install-Module -Name PSScriptAnalyzer"
}

$baseFolder = "$PSScriptRoot\.."

Invoke-ScriptAnalyzer -path $baseFolder -ExcludeRule PSUseToExportFieldsInManifest
Invoke-ScriptAnalyzer -path (Join-Path $baseFolder "Scripts")
Invoke-ScriptAnalyzer -path (Join-Path $baseFolder "Examples") -ExcludeRule PSAvoidUsingCmdletAliases,PSAvoidUsingPositionalParameters