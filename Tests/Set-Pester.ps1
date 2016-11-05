param(
[ValidateNotNullOrEmpty()]
[string] $baseUri = "localhost/VersionOne.Web",
[ValidateNotNullOrEmpty()]
[string] $token = "1.bxDPFh/9y3x9MAOt469q2SnGDqo="
)

     $env:V1_BASE_URI = $baseUri
     $env:V1_API_TOKEN = $token
	 if ( ${Function:Set-V1Connection} )
	 {
		Set-V1Connection -baseUri $baseUri -token $token
	 }

