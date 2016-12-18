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
    Write-Warning "Using existing V1 API values from `$env:V1_BASE_URI ($env:V1_BASE_URI) and `$env:V1_API_TOKEN ($env:V1_API_TOKEN).  Call Set-V1Connection to change them."
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

.Parameter SkipTest
	If set will not test the connection

.Outputs
    Nothing, unless -test is set then will return its return

.Example
    Set-V1Connection -baseUri "localhost/VersionOne.Web" -token "1.bxDPFh/9y3x9MAOt469q2SnGDqo="

    Set the defaults with a token

.Example
    Set-V1Connection -baseUri "localhost/VersionOne.Web" -credential (Get-Credential)

    Set the defaults with a credential object.  This will prompt you for credentials
#>
function Set-V1Connection
{
[CmdletBinding(SupportsShouldProcess)]
param(
[ValidateNotNullOrEmpty()]
[string] $BaseUri = "localhost/VersionOne.Web",
[Parameter(ParameterSetName="Credential",Mandatory)]
[PSCredential] 
[System.Management.Automation.Credential()]
$Credential,
[Parameter(ParameterSetName="Token",Mandatory)]
[string] $Token,
[switch] $SkipTest)

    Set-StrictMode -Version Latest

    if ( $PSCmdlet.ShouldProcess("","Set `$script values"))
    {
        $script:baseUri = $BaseUri

        if ( $Token )
        {
            $script:authorizationHeader = @{AUTHORIZATION="Bearer $Token"}
        }
        else
        {
            $script:credential = $Credential
        }

        if ( -not $SkipTest )
        {
            return Test-V1Connection
        }
    }
}

New-Alias -Name v1conn -Value Set-V1Connection