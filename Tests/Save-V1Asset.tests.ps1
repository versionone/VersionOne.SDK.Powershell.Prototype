Import-Module (Join-Path $PSScriptRoot ..\V1.psm1)

Describe "SaveV1Asset" {
    $script:prevInfoSetting = $InformationPreference
    $script:deleteMe = @()

    BeforeAll {
        $InformationPreference = "Continue"
    }

	It "Creates and save a story" {
        $story = New-V1Asset Story -attributes @{Name="Test";Scope="Scope:0"}
        $story | Should not be $null

        $savedStory = Save-V1Asset $story
        $savedStory | Should not be $null
        $savedStory.id | Should not beNullOrEmpty
        $script:deleteMe += $savedStory.id
        Write-Information "Added story with id of $($savedStory.id) -- clean this up"
                
	}

	It "Creates and saves 5 stories via pipeline" {
        $stories = (1..5) | ForEach-Object { New-V1Asset Story -attributes @{Name="Test$_";Scope="Scope:0"}} | 
            Save-V1Asset
        $stories | Should not be $null
        $stories.Count | Should be 5

        foreach ( $savedStory in $stories )
        {
            $savedStory | Should not be $null
            $savedStory.id | Should not beNullOrEmpty
            $script:deleteMe += $savedStory.id
            Write-Information "Added story with id of $($savedStory.id) -- clean this up"
        }
	}

    It "Updates a category" {
        $epicCat = (Get-V1Asset EpicCategory -attributes Name,Description) | Select -First 1
        $epicCat | Should not be $null

        $now = (Get-Date).ToString()
        $epicCat.Description = $now
        $savedCat = Save-V1Asset $epicCat
        $savedCat | Should not be $null

        $retrievedEpic = Get-V1Asset EpicCategory -id $savedCat.id
        $retrievedEpic.Description | Should be $now
    }

    AfterAll {
        $script:deleteMe | Remove-V1Asset
        Write-Information "Nevermind, I removed them." 
        $InformationPreference = $script:prevInfoSetting
    }
}