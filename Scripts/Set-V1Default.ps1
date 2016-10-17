$script:baseUri = $env:V1_BASE_URI
if ( $env:V1_API_TOKEN)
{
    $script:authorizationHeader = @{AUTHORIZATION="Bearer $env:V1_API_TOKEN"}
}
else
{
    $script:authorizationHeader = @{}
}
if ( $script:authorizationHeader -or $script:baseUri )
{
    Write-Warning "Using existing V1 API values from `$env:V1_BASE_URI and `$env:V1_API_TOKEN.  Call Set-V1Default to change them."
}

function Set-V1Default
{
param(
[Parameter(Mandatory)]
[string] $baseUri,
[Parameter(Mandatory,ParameterSetName="User")]
[string] $user,
[Parameter(Mandatory,ParameterSetName="User")]
[securestring] $password,
[Parameter(Mandatory,ParameterSetName="Token")]
[string] $token)

    Set-StrictMode -Version Latest

    $script:baseUri = $baseUri

    if ( $PSCmdlet.ParameterSetName -eq "Token")
    {
        $script:authorizationHeader = @{AUTHORIZATION="Bearer $token"}
    }
    else 
    {
        $script:authorizationHeader = @{AUTHORIZATION="Basic "+$([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("${username}:$password" )))}    
    }
}


function Get-V1BaseUri
{
    if ( $script:baseUri )
    {
        return $script:baseUri
    }
    else
    {
        Write-Error "Call Set-V1Default to set base Uri and credentials"    
    }

}