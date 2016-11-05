$script:baseUri = $env:V1_BASE_URI
if ( $env:V1_API_TOKEN)
{
    $script:authorizationHeader = @{AUTHORIZATION="Bearer $env:V1_API_TOKEN"}
}
else
{
    $script:authorizationHeader = $null
}
if ( $script:authorizationHeader -or $script:baseUri )
{
    Write-Warning "Using existing V1 API values from `$env:V1_BASE_URI ($env:V1_BASE_URI) and `$env:V1_API_TOKEN ($env:V1_API_TOKEN).  Call Set-V1Default to change them."
}
$script:credential = $null

<#
.Synopsis
	Set the Uri and credentials to use for V1 API calls
	
.Parameter BaseUri
	The base Uri to use, e.g. localhost/VersionOne.Web

.Parameter Credential
	PSCredential object of the user, or user name and it will prompt for password

.Parameter Token
	V1 Application token

.Example
    Set-V1Default -baseUri "localhost/VersionOne.Web" -token "1.bxDPFh/9y3x9MAOt469q2SnGDqo="

    Set the defaults with a token    

.Example
    Set-V1Default -baseUri "localhost/VersionOne.Web" -credential (Get-Credential)

    Set the defaults with a credential object.  This will prompt you for credentials    
#>
function Set-V1Default
{
param(
[Parameter(Mandatory)]
[string] $BaseUri,
[Parameter(Mandatory,ParameterSetName="User")]
[System.Management.Automation.CredentialAttribute()]
[PSCredential] $Credential,
[Parameter(Mandatory,ParameterSetName="Token")]
[string] $Token)

    Set-StrictMode -Version Latest

    $script:baseUri = $BaseUri

    if ( $PSCmdlet.ParameterSetName -eq "Token")
    {
        $script:authorizationHeader = @{AUTHORIZATION="Bearer $Token"}
    }
    else 
    {
        $script:credential = $Credential    
    }
}


<#
.Synopsis
	Get the Uri set be Set-V1Default

.Outputs 
    the base Uri used for all calls
#>
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