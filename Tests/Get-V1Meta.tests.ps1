Import-Module (Join-Path $PSScriptRoot ..\V1.psm1)
Set-V1Default -baseUri "localhost/VersionOne.Web" -token "1.bxDPFh/9y3x9MAOt469q2SnGDqo="

Describe "GetV1Meta" {

	It "Gets the metadata" {

        Get-V1BaseUri | Should not be $null

        $meta = Get-V1Meta
		$meta | Should not be $null
	}
}