Import-Module (Join-Path $PSScriptRoot ..\V1.psm1)

Describe "Get-V1AssetPaged" {

	It "Gets EpicCategories paged" {

         $ret = Get-V1AssetPaged EpicCategory -Attribute Name -start 0 -pagesize 1
		 $ret | Should not be $null
		 $ret.Assets | Should not be $null
		 $ret.Total -gt 1 | Should be $true

         $ret = Get-V1AssetPaged EpicCategory -Attribute Name -start 0 -pagesize 3
		 $ret | Should not be $null
		 $ret.Assets | Should not be $null
		 $ret.Assets.Count | Should be 3
		 $ret.Total -gt $ret.Assets.Count | Should be $true
	}

}