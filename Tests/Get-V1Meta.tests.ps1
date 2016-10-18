Import-Module (Join-Path $PSScriptRoot ..\V1.psm1)

Describe "GetV1Meta" {

	It "Gets the metadata" {

        Get-V1BaseUri | Should not be $null

        $meta = Get-V1Meta
		$meta | Should not be $null
	}
}