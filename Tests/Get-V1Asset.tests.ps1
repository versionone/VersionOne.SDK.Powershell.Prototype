Import-Module (Join-Path $PSScriptRoot ..\V1.psm1)
Set-V1Default -baseUri "localhost/VersionOne.Web" -token "1.bxDPFh/9y3x9MAOt469q2SnGDqo="

Describe "GetV1Asset" {

	It "Gets all Epics" {

         $c = Get-V1Asset Epic
		 $c | Should not be $null
		 ($c.Count -gt 0) | Should be $true
	}

	It "Gets all Scope 0 by ID" {

         Get-V1Asset Scope -ID 0 | Should not be $null
         Get-V1Asset Scope -ID Scope:0 | Should not be $null
	}

	It "Gets all Just the name of EpicCategories" {

         $c = Get-V1Asset EpicCategory -properties Name
		 $c | Should not be $null
		 ($c.Count -gt 0) | Should be $true

		($c[0] | Get-Member -MemberType Properties ).Count | Should be 3
		Get-Member -InputObject $c[0] -Name "AssetType" | Should not be $null
		Get-Member -InputObject $c[0] -Name "id" | Should not be $null
		Get-Member -InputObject $c[0] -Name "Name" | Should not be $null

	}
}