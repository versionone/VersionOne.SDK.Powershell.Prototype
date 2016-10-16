
function Set-V1Default
{
param(
[Parameter(Mandatory)]
[string] $baseUri,
[Parameter(Mandatory)]
[string] $token)

    Set-StrictMode -Version Latest
    
    $PSDefaultParameterValues = @{"*-V1*:baseUri"=$baseUri;"*-V1*:token"=$token}

}
