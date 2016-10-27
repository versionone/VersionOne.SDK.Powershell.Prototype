Import-Module (Join-Path $PSScriptRoot ..\V1.psm1)

Describe "SetV1Value" {

    function makeFakeEpic($i)
    {
        return [PSCustomObject]@{AssetType="Epic";Name="Test$i"}
    }

	It "Sets a number with a number" {

        $epic = Set-V1Value $(makeFakeEpic) -name Swag -value 123
        $epic.Swag | Should be 123
        $epic.Swag | Should beOfType Decimal
	}

	It "Sets a number with a string" {

        $epic = Set-V1Value $(makeFakeEpic) -name Swag -value "123"
        $epic.Swag | Should be 123
        $epic.Swag | Should beOfType Decimal
	}

	It "Sets a string with a string" {

        $epic = Set-V1Value $(makeFakeEpic) -name Name -value "NewName"
        $epic.Name | Should be "Newname"
	}

	It "Sets a string with a number" {

        $epic = Set-V1Value $(makeFakeEpic) -name Name -value 123
        $epic.Name | Should be "123"
	}

	It "Sets a string using the pipeline" {

        $i = 1
        $updatedEpics = (1..10) | ForEach-Object { makeFakeEpic $_ } | Set-V1Value -name Name -value (($i++)*100)
        $updatedEpics.Count | Should be 10
        $updatedEpics | ForEach-Object { $_.Name | Should belike "*00"} 
	}

    It "Tries to set a readonly attribute" {
        { Set-V1Value $(makeFakeEpic) -name CreateReason -value "CreateReason" } | Should throw
    }

    It "Tries to set a missing attribute" {
        { Set-V1Value $(makeFakeEpic) -name NotFoundHere -value "ow!" } | Should throw
    }
    
}