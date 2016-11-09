Import-Module (Join-Path $PSScriptRoot ..\V1.psm1)

Describe "Get-V1Asset" {

	It "Gets all Scopes" {

         $c = Get-V1Asset Scope
		 $c | Should not be $null
		 ($c.Count -gt 1) | Should be $true
	}

	It "Gets Scope 0 by ID" {

         Get-V1Asset Scope -ID 0 | Should not be $null
         Get-V1Asset Scope -ID Scope:0 | Should not be $null
	}

	It "Gets just the name of EpicCategories" {

         $c = Get-V1Asset EpicCategory -attributes Name
		 $c | Should not be $null
		 ($c.Count -gt 1) | Should be $true

		($c[0] | Get-Member -MemberType Properties ).Count | Should be 3
		Get-Member -InputObject $c[0] -Name "AssetType" | Should not be $null
		Get-Member -InputObject $c[0] -Name "id" | Should not be $null
		Get-Member -InputObject $c[0] -Name "Name" | Should not be $null

	}

	It "Gets EpicCategories sorted by name" {

         $c = Get-V1Asset EpicCategory -attributes Name -sort Name
		 $c | Should not be $null
		 ($c.Count -gt 1) | Should be $true

		 $sortedNames = $c.Name | Sort-Object
		 (0..($sortedNames.Count-1)) | ForEach-Object { $sortedNames[$_] | Should be $c[$_].Name }
	}

	It "Gets EpicCategory with name feature using string" {

         $c = Get-V1Asset EpicCategory -attributes Name -filter "Name='Feature'"
		 $c | Should not be $null

		 $c.Name | Should be 'Feature'
	}

	It "Gets EpicCategory with name feature using scriptBlock" {

		$ec = Get-V1FilterAsset EpicCategory
		$ec | Should not be $null

        $c = Get-V1Asset EpicCategory -attributes Name -filter { $ec.Name -eq "Feature"}
		$c | Should not be $null

		$c.Name | Should be 'Feature'
	}

	It "Gets epics on AssetState" {
		@(Get-V1Asset EpicCategory -filter "AssetState='64'").Count | Should not be 0
	}
	
	It "Gets epics with find" {
		@(Get-V1Asset EpicCategory -find "Non").Count | Should not be 0
	}

	It "Gets epics with findin" {
		@(Get-V1Asset EpicCategory -find "Non" -findin "Name").Count | Should not be 0
	}

	It "Tries to get invalid asset id " {
		 Get-V1Asset Story -ID 99999999  | should be $null
	}
	
	It "Tries to get invalid asset type" {
		 { Get-V1Asset blah } | should throw "blah was not found in meta"
	}
}