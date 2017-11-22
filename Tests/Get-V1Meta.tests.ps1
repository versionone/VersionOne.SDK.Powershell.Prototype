Import-Module (Join-Path $PSScriptRoot ..\VersionOneSdk.psm1)

Describe "Get-V1Meta" {

	It "Gets the metadata" {

        Get-V1BaseUri | Should not be $null

        $meta = Get-V1Meta
		$meta | Should not be $null
	}
}