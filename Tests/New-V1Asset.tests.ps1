Import-Module (Join-Path $PSScriptRoot ..\V1.psm1)

Describe "NewV1Asset" {

	It "Creates an minimal epic" {
        $epic = New-V1Asset Epic -properties @{Name="Test";Scope="Scope:0"}
        $epic | Should not be $null
        (Get-Member -InputObject $epic -Name "Name") | Should not be $Null
        (Get-Member -InputObject $epic -Name "Scope") | Should not be $Null
        (Get-Member -InputObject $epic -Name "id") | Should be $Null
        $epic.Name | Should be "Test"
        $epic.Scope | Should be "Scope:0"
	}

	It "Creates an epic with more items" {
        $plannedStart = Get-Date
        $epic = New-V1Asset Epic -properties @{Name="Test";Scope="Scope:0"} -default @{PlannedStart=$plannedStart;RequestedBy="YoMama"}
        $epic | Should not be $null
        (Get-Member -InputObject $epic -Name "Name") | Should not be $Null
        (Get-Member -InputObject $epic -Name "Scope") | Should not be $Null
        (Get-Member -InputObject $epic -Name "id") | Should be $Null
        (Get-Member -InputObject $epic -Name "RequestedBy") | Should not be $Null
        (Get-Member -InputObject $epic -Name "PlannedStart") | Should not be $Null
        $epic.RequestedBy | Should be "YoMama"
        $epic.PlannedStart | Should be $plannedStart
	}

	It "Tries to create an epic without required property" {
		 { New-V1Asset Epic -properties @{Name="Test"}} | Should throw
	}

	It "Tries creates an epic without required property with -addMissingRequired" {
		$epic = New-V1Asset Epic -properties @{Name="Test"} -addMissingRequired
        $epic | Should not be $null
        (Get-Member -InputObject $epic -Name "Name") | Should not be $Null
        (Get-Member -InputObject $epic -Name "Scope") | Should not be $Null
                 
	}
}