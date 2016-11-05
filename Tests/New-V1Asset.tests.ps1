Import-Module (Join-Path $PSScriptRoot ..\V1.psm1)

Describe "New-V1Asset" {

    It "Creates an minimal epic with hashtable" {
        $epic = New-V1Asset Epic -attributes @{Name="Test";Scope="Scope:0"}
        $epic | Should not be $null
        (Get-Member -InputObject $epic -Name "Name") | Should not be $Null
        (Get-Member -InputObject $epic -Name "Scope") | Should not be $Null
        (Get-Member -InputObject $epic -Name "id") | Should be $Null
        $epic.Name | Should be "Test"
        $epic.Scope | Should be "Scope:0"
    }

    It "Creates an epic with more items with hashtable" {
        $plannedStart = Get-Date
        $epic = New-V1Asset Epic -attributes @{Name="Test";Scope="Scope:0"} -default @{PlannedStart=$plannedStart;RequestedBy="YoMama"}
        $epic | Should not be $null
        (Get-Member -InputObject $epic -Name "Name") | Should not be $Null
        (Get-Member -InputObject $epic -Name "Scope") | Should not be $Null
        (Get-Member -InputObject $epic -Name "id") | Should be $Null
        (Get-Member -InputObject $epic -Name "RequestedBy") | Should not be $Null
        (Get-Member -InputObject $epic -Name "PlannedStart") | Should not be $Null
        $epic.RequestedBy | Should be "YoMama"
        $epic.PlannedStart | Should be $plannedStart
    }

    It "Creates an minimal epic with name/value" {
        $epic = New-V1Asset Epic -Names "Name","Scope" -values "Test","Scope:0"
        $epic | Should not be $null
        (Get-Member -InputObject $epic -Name "Name") | Should not be $Null
        (Get-Member -InputObject $epic -Name "Scope") | Should not be $Null
        (Get-Member -InputObject $epic -Name "id") | Should be $Null
        $epic.Name | Should be "Test"
        $epic.Scope | Should be "Scope:0"
    }

    It "Creates an epic with more items with name/value" {
        $plannedStart = Get-Date
        $epic = New-V1Asset Epic -Names "Name","Scope" -values "Test","Scope:0" -default @{PlannedStart=$plannedStart;RequestedBy="YoMama"}
        $epic | Should not be $null
        (Get-Member -InputObject $epic -Name "Name") | Should not be $Null
        (Get-Member -InputObject $epic -Name "Scope") | Should not be $Null
        (Get-Member -InputObject $epic -Name "id") | Should be $Null
        (Get-Member -InputObject $epic -Name "RequestedBy") | Should not be $Null
        (Get-Member -InputObject $epic -Name "PlannedStart") | Should not be $Null
        $epic.RequestedBy | Should be "YoMama"
        $epic.PlannedStart | Should be $plannedStart
    }

    It "Tries to create an epic without required attribute" {
        { New-V1Asset Epic -attributes @{Name="Test"}} | Should throw
    }

    It "Tries creates an epic without required attribute with -addMissingRequired" {
        $epic = New-V1Asset Epic -attributes @{Name="Test"} -addMissingRequired
        $epic | Should not be $null
        (Get-Member -InputObject $epic -Name "Name") | Should not be $Null
        (Get-Member -InputObject $epic -Name "Scope") | Should not be $Null
                 
    }
}