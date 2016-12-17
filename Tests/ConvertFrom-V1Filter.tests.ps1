Import-Module (Join-Path $PSScriptRoot ..\VersionOneSdk.psm1)

Describe "ConvertFromV1Filter" {

    $story = Get-V1FilterAsset Story

	It " Filter assets to only those that have a non-zero To Do and are owned by Member with ID 20." {

         ConvertFrom-V1Filter { $story.ToDo -eq 0} | Should be "ToDo='0'"
	}

	It "Filter assets to only those that have a non-zero To Do and are owned by a Member with ID 20, 21, or 22." {

         ConvertFrom-V1Filter { $story.ToDo -ne 0 -and $story.Owners -eq 'Member:20','Member:21','Member:22' } | Should be "ToDo!='0';Owners='Member:20','Member:21','Member:22'"
	}

	It "Filter assets to only those whose name is equal to the string `"Can't Boot`". Notice the quote character has been escaped by doubling." {

         ConvertFrom-V1Filter { $story.Name -eq "Can't Boot" } | Should be "Name='Can''t Boot'"
	}

	It "Filter assets to only those that are owned by more than 5 Members." {

         ConvertFrom-V1Filter { $story.Owners.Count -gt 5 } | Should be "Owners.@Count>'5'"
	}

	It "Filter assets to only those that have an Estimate less than 1." {

         ConvertFrom-V1Filter { $story.Estimate -lt 1 } | Should be "Estimate<'1'"
	}

	It "Filter assets to only those that are owned by a Member with ID 20 or 21 OR belong to a Scope (Project) with ID 5." {

         ConvertFrom-V1Filter { $story.Owners -eq 'Member:20','Member:21' -or $story.Scope -eq 'Scope:5' } | Should be "Owners='Member:20','Member:21'|Scope='Scope:5'"
	}

	It "Filter assets to only those that have a non-zero To Do AND are owned by a Member with ID 20 OR those that have a 0 To Do AND are owned by a Member with ID 20 or 21." {

         ConvertFrom-V1Filter { ($story.ToDo -ne 0 -and $story.Owners -eq 'Member:20') -or ($story.ToDo -eq 0 -and $story.Owners -eq 'Member:20','Member:21') } | Should be "(ToDo!='0';Owners='Member:20')|(ToDo='0';Owners='Member:20','Member:21')"
	}

	It "Single quote escaped" {

         ConvertFrom-V1Filter { $story.Name -eq 'test''s' } | Should be "Name='test''s'"
	}
    
	It "Tests double quote escape" {

         ConvertFrom-V1Filter { $story.Name -eq "test's" } | Should be "Name='test''s'"
	}
    
}