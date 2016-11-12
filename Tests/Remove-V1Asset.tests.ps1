Import-Module (Join-Path $PSScriptRoot ..\V1.psm1)

Describe "Remove-V1Asset" {
    $script:prevInfoSetting = $InformationPreference

    BeforeAll {
        $InformationPreference = "Continue"
    }

	It "Adds and removes one story" {
        $savedStory = New-V1Asset Story -Attribute @{Name="Test";Scope="Scope:0"} | Save-V1Asset 
        $savedStory | Should not be $null
        $savedStory.id | Should not beNullOrEmpty

        $removedStory = Remove-V1Asset $savedStory.id
        $removedStory.StartsWith($savedStory.id) | Should be $true
        ($removedStory -split ":").Count | Should be 3

        Get-V1Asset Story -ID $savedStory.id | Should be $null
	}

	It "Adds and removes one story with incorrect case for story" {
        $savedStory = New-V1Asset Story -Attribute @{Name="Test";Scope="Scope:0"} | Save-V1Asset 
        $savedStory | Should not be $null
        $savedStory.id | Should not beNullOrEmpty

        $removedStory = Remove-V1Asset $savedStory.id.ToLower()
        $removedStory.StartsWith($savedStory.id) | Should be $true
        ($removedStory -split ":").Count | Should be 3

        Get-V1Asset Story -ID ($savedStory.id).ToLower() | Should be $null
	}

	It "Creates and deletes 5 stories via pipeline" {
        $stories = (1..5) | ForEach-Object { New-V1Asset Story -Attribute @{Name="Test$_";Scope="Scope:0"}} | 
            Save-V1Asset
        $stories | Should not be $null
        $stories.Count | Should be 5

       $deletedStories = $stories | select -expandproperty id | Remove-V1Asset
       foreach ( $d in $deletedStories )
       {
            ($d -split ":").Count | Should be 3
       }  
	}

    AfterAll {
        $InformationPreference = $script:prevInfoSetting
    }
}