<#
.Synopsis
    Launch the browser with API help for the REST API

.helpType
    The type of help to retrieve    
#>
function Show-V1Help
{
param(
[ValidateSet("All","Filter","Sort","Where","Meta","Localization")]    
$helpType = "All"
)
    if ( Get-V1BaseUri )
    {
        $rest = "help/api/rest-1.html"

        switch ( $helpType )
        {
            "Filter" { $rest = "help/api/rest-1.html#section.filter.syntax" }
            "Where" { $rest = "help/api/rest-1.html#section.filter.syntax" }
            "Sort" { $rest = "help/api/rest-1.html#section.orderby.syntax" }
            "Meta" { $rest = "help/api/meta.html" }
            "Localization" { $ret = "help/api/loc.html"}
        }

        Start-Process "http://$(Get-V1BaseUri)/$rest"
    }
    else 
    {
        Write-Warning "Call Set-V1Default to set the baseUri and credentials to be able to get help"    
    }
}