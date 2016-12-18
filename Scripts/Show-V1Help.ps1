<#
.Synopsis
    Launch the browser with API help for the REST API

.Parameter HelpType
    The type of help to retrieve
#>
function Show-V1Help
{
param(
[ValidateSet("All","Find","Filter","Sort","Where","Meta","Localization")]
$HelpType = "All"
)
    if ( Get-V1BaseUri )
    {
        switch ( $HelpType )
        {
            "Filter" { $rest = "help/api/rest-1.html#section.filter.syntax" }
            "Where" { $rest = "help/api/rest-1.html#section.filter.syntax" }
            "Sort" { $rest = "help/api/rest-1.html#section.orderby.syntax" }
            "Find" { $rest = "help/api/rest-1.html#query.data.find" }
            "Meta" { $rest = "help/api/meta.html" }
            "Localization" { $rest = "help/api/loc.html"}
            default { $rest = "help/api/rest-1.html" }
        }

        Start-Process "http://$(Get-V1BaseUri)/$rest"
    }
    else
    {
        Write-Warning "Call Set-V1Connection to set the baseUri and credentials to be able to get help"
    }
}

New-Alias -Name v1help -Value Show-V1Help