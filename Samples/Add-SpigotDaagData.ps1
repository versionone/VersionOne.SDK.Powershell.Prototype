<#
Port of data added in Spigot's delivery-at-a-glanc.json file
#>
[CmdletBinding()]
param(
[string] $testName = "PSTest", # name used for all names,
[string] $baseUri = "localhost/VersionOne.Web",
[string] $token = "1.GOXGCoUddEh9bpjlHJWKNIMvIHs=" # << jmwDemo, jmw V1 >> "1.bxDPFh/9y3x9MAOt469q2SnGDqo="
)

<#
.Synopsis
    Add or update a V1 Asset
#>
function Push-V1Asset
{
[CmdletBinding()]
param( 
[Parameter(Mandatory,ValueFromPipeline)]
$asset, 
[Parameter(Mandatory)]
[string] $filter)

process
{
    $value =  $ExecutionContext.InvokeCommand.ExpandString($filter)
    $ret = Get-V1Asset $asset.AssetType -filter $value
    if ( -not $ret )
    {
        $ret = Save-V1Asset $asset
        Write-Information "Added $($asset.AssetType) with attribute $value and Oid of $($ret.id)"
    }
    elseif ( @($ret).Count -gt 1 )
    {
        Write-Warning "$($asset.AssetType) with attribute $value has $($ret.Count) values, taking first one with Oid of $($ret.id)"
        $ret = $ret[0]
    }
    else
    {
        Write-Information "Skipping existing $($asset.AssetType) with attribute $value and Oid of $($ret.id)"
    }
    $ret
}

}

<#
.Synopsis
    Create n number of names with a number in them
#>
function New-V1TestName
{
param(
[Parameter(Mandatory)]
[ValidateRange(1,[Int]::MaxValue)]
$count, 
$prefix, 
$suffix)

    return (1..$count) | ForEach-Object { "$prefix$_$suffix" }
}


try
{

cls

Set-StrictMode -Version Latest
$error.Clear()
$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"

Write-Information "`n`n`n`n`n`Starting...."

$activityName = "Add Daag data"

Write-Progress -Activity $activityName -Status "Initializing"

Import-Module (Join-path $PSScriptRoot "..\V1.psm1") -Force
if ( -not (Set-V1Connection -baseUri $baseUri -token $token -test ))
{
    throw "Can't connect to $baseUri with token"
}
$null = Get-V1Meta


Write-Progress -Activity $activityName -Status "Adding phases"
$phases = "DevelopmentTrailing", "TestingTrailing","ProductionTrailing" |
            New-V1Asset -assetType Phase -Name Name -defaultAttributes @{ColorName="denim"} |
            Push-V1Asset -filter 'Name=''$($asset.Name)'''


Write-Progress -Activity $activityName -Status "Adding scheme"
$scheme = New-V1Asset -assetType Scheme -Name Name,SelectedValues -value "SchemeTrailing", 
    $($phases | Select-Object -expand id) |
    Push-V1Asset -filter 'Name=''$($asset.Name)'''


Write-Progress -Activity $activityName -Status "Adding scope"
$scope = New-V1Asset -assetType Scope -attributes @{
        Name = "TrailingCommitsScope"
        Parent="Scope:0"
        Scheme=$scheme
        BeginDate='2016-6-1'} |
    Push-V1Asset -filter 'Name=''$($asset.Name)'''

Write-Progress -Activity $activityName -Status "Adding Done Stories"
$stories =  New-V1TestName 5 "DoneStory" | New-V1Asset -assetType Story `
        -Name Name -DefaultAttributes @{
        Status="StoryStatus:135"
        Scope=$scope } |
    Push-V1Asset -filter 'Name=''$($asset.Name)'''

Write-Progress -Activity $activityName -Status "Adding Done ChangeSets"
$i = 0
$doneChangeSets =  $stories | ForEach-Object {  New-V1Asset -assetType ChangeSet `
        -Name Name,PrimaryWorkitems -Value "DoneChangeSet$i",$_; $i++ } |
    Push-V1Asset -filter 'Name=''$($asset.Name)'''

Write-Progress -Activity $activityName -Status "Adding Stories"
$stories =  New-V1TestName 10 "Story" | New-V1Asset -assetType Story `
        -Name Name -DefaultAttributes @{
        Scope=$scope } |
    Push-V1Asset -filter 'Name=''$($asset.Name)'''

Write-Progress -Activity $activityName -Status "Adding ChangeSets"
$i = 0
$changeSets =  $stories | ForEach-Object {  New-V1Asset -assetType ChangeSet `
        -Name Name,PrimaryWorkitems -Value "ChangeSet$i",$_; $i++ } |
    Push-V1Asset -filter 'Name=''$($asset.Name)'''

Write-Progress -Activity $activityName -Status "Adding Defect"
$defect =  New-V1Asset -assetType Defect `
        -Name Name,Scope -Value "SpreadDefect",$scope |
    Push-V1Asset -filter 'Name=''$($asset.Name)'''

Write-Progress -Activity $activityName -Status "Adding Defect ChangeSets"
$spreadChangeSetsDev =  New-V1TestName 3 "ChangeSetForSpreadDefect_Dev" |  New-V1Asset -assetType ChangeSet `
        -Name Name -defaultAttributes @{PrimaryWorkitems=$defect}   |
    Push-V1Asset -filter 'Name=''$($asset.Name)'''

$spreadChangeSetsTest =  New-V1TestName 3 "ChangeSetForSpreadDefect_Test" |  New-V1Asset -assetType ChangeSet `
        -Name Name -defaultAttributes @{PrimaryWorkitems=$defect}   |
    Push-V1Asset -filter 'Name=''$($asset.Name)'''

$spreadChangeSetsStage =  New-V1TestName 3 "ChangeSetForSpreadDefect_Stg" |  New-V1Asset -assetType ChangeSet `
        -Name Name -defaultAttributes @{PrimaryWorkitems=$defect}   |
    Push-V1Asset -filter 'Name=''$($asset.Name)'''

Write-Progress -Activity $activityName -Status "Adding Rogue ChangeSets"
$rougueChangeSets =  New-V1TestName 10 "RogueChangeSet" |  New-V1Asset -assetType ChangeSet `
        -Name Name |
    Push-V1Asset -filter 'Name=''$($asset.Name)'''

Write-Progress -Activity $activityName -Status "Adding Shared Stories"
$storiesForSharing =  New-V1TestName 2 "StorySharingChangeSet" | New-V1Asset -assetType Story `
        -Name Name -DefaultAttributes @{
        Scope=$scope.Id } |
    Push-V1Asset -filter 'Name=''$($asset.Name)'''

Write-Progress -Activity $activityName -Status "Adding Shared ChangeSet"
$sharedChangeSets = New-V1Asset -assetType ChangeSet `
        -Name Name -Value "SharedChangeSet" -defaultAttributes @{PrimaryWorkitems=$storiesForSharing}   |
    Push-V1Asset -filter 'Name=''$($asset.Name)'''

Write-Progress -Activity $activityName -Status "Adding Bundles"
$defaultValues = @{ PackageRevision = 1
                    IsCustomLabel = $false
                    PackageReference = "RoguePackage" }

$bundle = New-V1Asset -assetType Bundle `
        -Name Name,Phase,ChangeSets -Value "Bundle With Rogue",$phases[0],
            ($rougueChangeSets[0..2]+$changeSets[0]) -defaultAttributes $defaultValues |
    Push-V1Asset -filter 'Name=''$($asset.Name)'''

$bundle = New-V1Asset -assetType Bundle `
        -Name Name,Phase,ChangeSets -Value "Bundle With Rogue",$phases[1],
            ($rougueChangeSets[0..2]+$changeSets[0..1]) -defaultAttributes $defaultValues |
    Push-V1Asset -filter 'Name=''$($asset.Name)'''

$bundle = New-V1Asset -assetType Bundle `
        -Name Name,Phase,ChangeSets -Value "Bundle With Rogue",$phases[2],
            ($rougueChangeSets[2..3]+$changeSets[2]) -defaultAttributes $defaultValues |
    Push-V1Asset -filter 'Name=''$($asset.Name)'''


$defaultValues = @{ PackageRevision = 1
                    IsCustomLabel = $false
                    PackageReference = "BundleIn3Phases" }

$bundle = New-V1Asset -assetType Bundle `
        -Name Name,Phase,ChangeSets -Value "Bundle In 3 Phases Only in Last Phase1", $phases[0],
            $doneChangeSets[0..4] -defaultAttributes $defaultValues |
    Push-V1Asset -filter 'Name=''$($asset.Name)'''

$bundle = New-V1Asset -assetType Bundle `
        -Name Name,Phase,ChangeSets -Value "Bundle In 3 Phases Only in Last Phase2", $phases[1],
            $doneChangeSets[0..4] -defaultAttributes $defaultValues |
    Push-V1Asset -filter 'Name=''$($asset.Name)'''

$bundle = New-V1Asset -assetType Bundle `
        -Name Name,Phase,ChangeSets -Value "Bundle In 3 Phases Only in Last Phase3", $phases[2],
            $doneChangeSets[0..4] -defaultAttributes $defaultValues |
    Push-V1Asset -filter 'Name=''$($asset.Name)'''

$defaultValues = @{ PackageRevision = 1
                    IsCustomLabel = $false
                    PackageReference = "BundleWithDoneAndNotDone" }

$bundle = New-V1Asset -assetType Bundle `
        -Name Name,Phase,ChangeSets -Value "Bundle In 1 Phases with Done and not done items1",$phases[1],
            ($doneChangeSets[0..2]+$changeSets[0..2]) -defaultAttributes $defaultValues |
    Push-V1Asset -filter 'Name=''$($asset.Name)'''

$bundle = New-V1Asset -assetType Bundle `
        -Name Name,Phase,ChangeSets -Value "Bundle with defect spread across many phases1",$phases[0],
            $spreadChangeSetsDev -defaultAttributes $defaultValues |
    Push-V1Asset -filter 'Name=''$($asset.Name)'''

$bundle = New-V1Asset -assetType Bundle `
        -Name Name,Phase,ChangeSets -Value "Bundle with defect spread across many phases2",$phases[1],
            $spreadChangeSetsTest -defaultAttributes $defaultValues |
    Push-V1Asset -filter 'Name=''$($asset.Name)'''

$bundle = New-V1Asset -assetType Bundle `
        -Name Name,Phase,ChangeSets -Value "Bundle with defect spread across many phases3",$phases[1],
            $spreadChangeSetsStage -defaultAttributes $defaultValues |
    Push-V1Asset -filter 'Name=''$($asset.Name)'''

$defaultValues.PackageReference = "SharedChangeSetPackage"
$bundle = New-V1Asset -assetType Bundle `
        -Name Name,Phase,ChangeSets -Value "Bundle with a ChangeSet shared by multiple workitems",$phases[2],
            $sharedChangeSets -defaultAttributes $defaultValues |
    Push-V1Asset -filter 'Name=''$($asset.Name)'''


Write-Progress -Activity $activityName -Completed

}
catch
{
    # without try/catch, error message won't have full stack
    Write-Error "Exception!`n$_`n$($_.ScriptStackTrace)"
}