[CmdletBinding()]
param(
[ValidateNotNullOrEmpty()]
[string] $BaseUri = "localhost/VersionOne.Web",
[PSCredential] 
[System.Management.Automation.Credential()] $Credential,
[string] $Token
)
	if ( -not $Token -and (-not $Credential))
	{
		throw "Must supply token or credential"
	}

     $env:V1_BASE_URI = $baseUri
     $env:V1_API_TOKEN = $Token
	 if ( ${Function:Set-V1Connection} )
	 {
		Set-V1Connection -baseUri $BaseUri @PSBoundParameters -test
	 }

