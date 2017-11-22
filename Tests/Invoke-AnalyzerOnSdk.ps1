<#
Run the script analyzer on all the code
#>
[CmdletBinding()]
param()

if ( -not ( Get-Module PSScriptAnalyzer))
{
    throw "Analyzer not found.  As Admin, run:  Install-Module -Name PSScriptAnalyzer"
}

$baseFolder = Convert-Path "$PSScriptRoot\.."

Write-Verbose "Checking $baseFolder..."
Invoke-ScriptAnalyzer -path $baseFolder -ExcludeRule PSUseToExportFieldsInManifest -verbose:$false
Write-Verbose "Checking $(Join-Path $baseFolder "Scripts")..."
Invoke-ScriptAnalyzer -path (Join-Path $baseFolder "Scripts") -verbose:$false
Write-Verbose "Checking $(Join-Path $baseFolder "Examples")..."
Invoke-ScriptAnalyzer -path (Join-Path $baseFolder "Examples") -ExcludeRule PSAvoidUsingCmdletAliases,PSAvoidUsingPositionalParameters -verbose:$false