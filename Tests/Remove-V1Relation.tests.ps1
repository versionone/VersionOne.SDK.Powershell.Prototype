Import-Module (Join-Path $PSScriptRoot ..\VersionOneSdk.psm1)

Describe "Remove-V1Relation" {

    Get-V1BaseUri | Should not be $null
    $script:deleteMe = @()

	It "Removea a single relation" {

        $story = New-V1Asset Story -Attribute @{Name="DeleteMe$(Get-Date)";Scope="Scope:0";Status="StoryStatus:133"} | Save-V1Asset
        $story | Should not be $null
        $script:deleteMe += $story 

        $story = Get-V1Asset Story -id $story.id -Attribute Status
        $story  | Should not be $null 
        $story.Status | Should not be $null 

        Remove-V1Relation $story -Attribute Status -ID $story.Status | Should not be $null 

        $story = Get-V1Asset Story -id $story.id -Attribute Status
        $story  | Should not be $null 
        $story.Status | Should be $null 
	}

	It "Removes a multi relation and single relation" {

        $members = Get-V1Asset Member -Attribute Name
        $members | Should not be $null 
        @($members).Count -gt 2 | Should be $true 

        $story = New-V1Asset Story -Attribute @{Name="DeleteMe$(Get-Date)";Scope="Scope:0";Owners=$members[0..2];Status="StoryStatus:133"} | Save-V1Asset
        $story | Should not be $null
        $script:deleteMe += $story 

        $story = Get-V1Asset Story -id $story.id -Attribute Status,Owners
        $story  | Should not be $null 
        $story.Status | Should not be $null 
        $story.Owners | Should not be $null 
        @($story.Owners).Count | Should be 3 

        Remove-V1Relation $story -Attribute Owners -ID $story.Owners[0] | Should not be $null 
        Remove-V1Relation $story -Attribute Status -ID $story.Status | Should not be $null 

        $story = Get-V1Asset Story -id $story.id -Attribute Status,Owners
        $story  | Should not be $null 
        $story.Status | Should be $null 
        $story.Owners | Should not be $null 
        @($story.Owners).Count | Should be 2 
	}

	It "Removes a multi relation" {

        $members = Get-V1Asset Member -Attribute Name
        $members | Should not be $null 
        @($members).Count -gt 2 | Should be $true 

        $story = New-V1Asset Story -Attribute @{Name="DeleteMe$(Get-Date)";Scope="Scope:0";Owners=$members[0..2];Status="StoryStatus:133"} | Save-V1Asset
        $story | Should not be $null
        $script:deleteMe += $story 

        $story = Get-V1Asset Story -id $story.id -Attribute Status,Owners
        $story  | Should not be $null 
        $story.Owners | Should not be $null 
        @($story.Owners).Count | Should be 3 

        Remove-V1Relation $story -Attribute Owners -ID $story.Owners[0] | Should not be $null 

        $story = Get-V1Asset Story -id $story.id -Attribute Status,Owners
        $story  | Should not be $null 
        $story.Owners | Should not be $null 
        @($story.Owners).Count | Should be 2 
	}

    AfterAll {
        $script:deleteMe.id | Remove-V1Asset
    }

}