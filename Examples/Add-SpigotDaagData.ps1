<#
Port of data added in Spigot's delivery-at-a-glanc.json file
#>
[CmdletBinding()]
param(
[string] $testName = "PSTest", # name used for all names,
[string] $baseUri = "localhost/VersionOne.Web",
[PSCredential] 
[System.Management.Automation.Credential()] $Credential,
[string] $token
)

$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"

. (Join-Path $PSScriptRoot Push-V1Asset.ps1)
. (Join-Path $PSScriptRoot New-V1TestName.ps1)

try
{

cls

Set-StrictMode -Version Latest
$error.Clear()


Write-Information "`n`n`n`n`n`Starting...."

$activityName = "Add Daag data"

Write-Progress -Activity $activityName -Status "Initializing"

Import-Module (Join-path $PSScriptRoot "..\VersionOneSdk.psm1") -Force
if ( -not (Set-V1Connection -baseUri $baseUri -token $token -cred $Credential -test ))
{
    throw "Can't connect to $baseUri with token"
}
$null = Get-V1Meta


Write-Progress -Activity $activityName -Status "Adding phases"
$phases = "DevelopmentTrailing", "TestingTrailing","ProductionTrailing" |
            New-V1Asset -assetType Phase -Name Name -DefaultAttribute @{ColorName="denim"} | Push-V1Asset

Write-Progress -Activity $activityName -Status "Adding scheme"
$scheme = New-V1Asset -assetType Scheme -Name Name,SelectedValues -value "SchemeTrailing", 
    $($phases | Select-Object -expand id) | Push-V1Asset

Write-Progress -Activity $activityName -Status "Adding scope"
$scope = New-V1Asset -assetType Scope -Attribute @{
        Name = "TrailingCommitsScope"
        Parent="Scope:0"
        Scheme=$scheme
        BeginDate='2016-6-1'} | Push-V1Asset

Write-Progress -Activity $activityName -Status "Adding Done Stories"
$stories =  New-V1TestName 5 "DoneStory" | New-V1Asset -assetType Story `
        -Name Name -DefaultAttribute @{
        Status="StoryStatus:135"
        Scope=$scope } | Push-V1Asset

Write-Progress -Activity $activityName -Status "Adding Done ChangeSets"
$i = 0
$doneChangeSets =  $stories | ForEach-Object {  New-V1Asset -assetType ChangeSet `
        -Name Name,PrimaryWorkitems -Value "DoneChangeSet$i",$_; $i++ } | Push-V1Asset

Write-Progress -Activity $activityName -Status "Adding Stories"
$stories =  New-V1TestName 10 "Story" | New-V1Asset -assetType Story `
        -Name Name -DefaultAttribute @{
        Scope=$scope } | Push-V1Asset

Write-Progress -Activity $activityName -Status "Adding ChangeSets"
$i = 0
$changeSets =  $stories | ForEach-Object {  New-V1Asset -assetType ChangeSet `
        -Name Name,PrimaryWorkitems -Value "ChangeSet$i",$_; $i++ } | Push-V1Asset

Write-Progress -Activity $activityName -Status "Adding Defect"
$defect =  New-V1Asset -assetType Defect `
        -Name Name,Scope -Value "SpreadDefect",$scope | Push-V1Asset

Write-Progress -Activity $activityName -Status "Adding Defect ChangeSets"
$spreadChangeSetsDev =  New-V1TestName 3 "ChangeSetForSpreadDefect_Dev" |  New-V1Asset -assetType ChangeSet `
        -Name Name -DefaultAttribute @{PrimaryWorkitems=$defect}   | Push-V1Asset

$spreadChangeSetsTest =  New-V1TestName 3 "ChangeSetForSpreadDefect_Test" |  New-V1Asset -assetType ChangeSet `
        -Name Name -DefaultAttribute @{PrimaryWorkitems=$defect} | Push-V1Asset

$spreadChangeSetsStage =  New-V1TestName 3 "ChangeSetForSpreadDefect_Stg" |  New-V1Asset -assetType ChangeSet `
        -Name Name -DefaultAttribute @{PrimaryWorkitems=$defect} | Push-V1Asset

Write-Progress -Activity $activityName -Status "Adding Rogue ChangeSets"
$rougueChangeSets =  New-V1TestName 10 "RogueChangeSet" |  New-V1Asset -assetType ChangeSet `
        -Name Name | Push-V1Asset

Write-Progress -Activity $activityName -Status "Adding Shared Stories"
$storiesForSharing =  New-V1TestName 2 "StorySharingChangeSet" | New-V1Asset -assetType Story `
        -Name Name -DefaultAttribute @{
        Scope=$scope.Id } | Push-V1Asset

Write-Progress -Activity $activityName -Status "Adding Shared ChangeSet"
$sharedChangeSets = New-V1Asset -assetType ChangeSet `
        -Name Name -Value "SharedChangeSet" -DefaultAttribute @{PrimaryWorkitems=$storiesForSharing} | Push-V1Asset

Write-Progress -Activity $activityName -Status "Adding Bundles"
$defaultValues = @{ PackageRevision = 1
                    IsCustomLabel = $false
                    PackageReference = "RoguePackage" }

$bundle = New-V1Asset -assetType Bundle `
        -Name Name,Phase,ChangeSets -Value "Bundle With Rogue",$phases[0],
            ($rougueChangeSets[0..2]+$changeSets[0]) -DefaultAttribute $defaultValues | Push-V1Asset

$bundle = New-V1Asset -assetType Bundle `
        -Name Name,Phase,ChangeSets -Value "Bundle With Rogue",$phases[1],
            ($rougueChangeSets[0..2]+$changeSets[0..1]) -DefaultAttribute $defaultValues | Push-V1Asset

$bundle = New-V1Asset -assetType Bundle `
        -Name Name,Phase,ChangeSets -Value "Bundle With Rogue",$phases[2],
            ($rougueChangeSets[2..3]+$changeSets[2]) -DefaultAttribute $defaultValues | Push-V1Asset

$defaultValues = @{ PackageRevision = 1
                    IsCustomLabel = $false
                    PackageReference = "BundleIn3Phases" }

$bundle = New-V1Asset -assetType Bundle `
        -Name Name,Phase,ChangeSets -Value "Bundle In 3 Phases Only in Last Phase1", $phases[0],
            $doneChangeSets[0..4] -DefaultAttribute $defaultValues | Push-V1Asset

$bundle = New-V1Asset -assetType Bundle `
        -Name Name,Phase,ChangeSets -Value "Bundle In 3 Phases Only in Last Phase2", $phases[1],
            $doneChangeSets[0..4] -DefaultAttribute $defaultValues | Push-V1Asset

$bundle = New-V1Asset -assetType Bundle `
        -Name Name,Phase,ChangeSets -Value "Bundle In 3 Phases Only in Last Phase3", $phases[2],
            $doneChangeSets[0..4] -DefaultAttribute $defaultValues | Push-V1Asset

$defaultValues = @{ PackageRevision = 1
                    IsCustomLabel = $false
                    PackageReference = "BundleWithDoneAndNotDone" }

$bundle = New-V1Asset -assetType Bundle `
        -Name Name,Phase,ChangeSets -Value "Bundle In 1 Phases with Done and not done items1",$phases[1],
            ($doneChangeSets[0..2]+$changeSets[0..2]) -DefaultAttribute $defaultValues | Push-V1Asset

$bundle = New-V1Asset -assetType Bundle `
        -Name Name,Phase,ChangeSets -Value "Bundle with defect spread across many phases1",$phases[0],
            $spreadChangeSetsDev -DefaultAttribute $defaultValues | Push-V1Asset

$bundle = New-V1Asset -assetType Bundle `
        -Name Name,Phase,ChangeSets -Value "Bundle with defect spread across many phases2",$phases[1],
            $spreadChangeSetsTest -DefaultAttribute $defaultValues | Push-V1Asset

$bundle = New-V1Asset -assetType Bundle `
        -Name Name,Phase,ChangeSets -Value "Bundle with defect spread across many phases3",$phases[1],
            $spreadChangeSetsStage -DefaultAttribute $defaultValues | Push-V1Asset

$defaultValues.PackageReference = "SharedChangeSetPackage"
$bundle = New-V1Asset -assetType Bundle `
        -Name Name,Phase,ChangeSets -Value "Bundle with a ChangeSet shared by multiple workitems",$phases[2],
            $sharedChangeSets -DefaultAttribute $defaultValues | Push-V1Asset


Write-Progress -Activity $activityName -Completed

}
catch
{
    # without try/catch, error message won't have full stack
    Write-Error "Exception!`n$_`n$($_.ScriptStackTrace)"
}