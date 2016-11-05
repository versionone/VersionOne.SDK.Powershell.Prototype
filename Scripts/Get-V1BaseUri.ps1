<#
.Synopsis
	Get the Uri set be Set-V1Connection

.Outputs 
    The base Uri used for all calls
#>
function Get-V1BaseUri
{
    if ( $script:baseUri )
    {
        return $script:baseUri
    }
    else
    {
        throw "Call Set-V1Connection to set base Uri and credentials"    
    }

}