<#
.Synopsis
    Tests the base Uri and credentials set with Set-V1Connection

.Description
    Gets Scope:0 from the server.  Use -Verbose to get details about any exceptions if it returns $false

.Outputs
    $true/$false
#>
function Test-V1Connection
{
[OutputType([Bool])]
[CmdletBinding()]
param()

    if ( -not (Get-V1BaseUri) )
    {
        throw "Must call Set-V1Connection to do anything."
    }

    try
    {
        $uri = "$(Get-V1BaseUri)/rest-1.v1/Data/Scope/0"
        Write-Verbose "Testing $uri "
        return ($null -ne (InvokeApi  $uri))
    }
    catch
    {
        Write-Verbose $_
        return $false
    }
}

New-Alias -Name v1test -Value Test-V1Connection