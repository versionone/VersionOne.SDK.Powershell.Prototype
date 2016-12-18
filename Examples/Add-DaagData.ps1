<#
Port of Valve's index.js file for loading Daag data
#>
[CmdletBinding()]
param(
[string] $testName = "PSTest", # name used for all names,
[string] $baseUri = "localhost/VersionOne.Web",
[PSCredential] 
[System.Management.Automation.Credential()]
$Credential,
[string] $token
)

try
{

cls

Set-StrictMode -Version Latest
$error.Clear()
$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"

Import-Module (Join-path $PSScriptRoot "..\VersionOneSdk.psm1") -Force
Set-V1Connection -baseUri $baseUri -token $token -cred $Credential -test
$null = Get-V1Meta

$activityName = "Add Daag data"

Write-Progress -Activity $activityName -Status "Initializing"

Write-Progress -Activity $activityName -Status "Loading scopes"
$scopes = Get-V1Asset -assetType "Scope" -Attribute "Name"

Write-Progress -Activity $activityName -Status "Loading schemes"
$schemes = Get-V1Asset -assetType "Scheme" -Attribute "Name"

Write-Progress -Activity $activityName -Status "Loading phases"
$phases = Get-V1Asset -assetType "Phase" -Attribute "Name"

Write-Progress -Activity $activityName -Status "Loading epic categories"
$epicCategories = Get-V1Asset -assetType "EpicCategory" -Attribute "Name"

Write-Progress -Activity $activityName -Status "Loading epics"
$epics = (Get-V1Asset -assetType "Epic")


$developmentPhase = $phases | Where-Object name -eq "Development"
$testingPhase = $phases | Where-Object name -eq "Testing"
$productionPhase = $phases | Where-Object name -eq "Production"

$epicCategory =       $epicCategories | Where-Object name -eq 'Epic'
$featureCategory =    $epicCategories | Where-Object name -eq 'Feature'
$subFeatureCategory = $epicCategories | Where-Object name -eq 'SubFeature'
$initiativeCategory = $epicCategories | Where-Object name -eq 'Initiative'

Write-Progress -Activity $activityName -Status "Adding new schemes, scopes, workitems"

$testScheme = "${testName}Scheme"
$testScope = "${testName}Scope"

# constants
$ROOT_SCOPE = 'Scope:0'
$DONE_STORY_STATUS = 'StoryStatus:135'

$scheme = $Schemes | Where-Object name -eq $testScheme | Select -first 1
if ( -not $scheme )
{
    Write-Information "Adding Scheme $testScheme"
    $schemeValues = $DONE_STORY_STATUS,$developmentPhase,$testingPhase,$productionPhase,$epicCategory,$featureCategory,$subFeatureCategory,$initiativeCategory
    $scheme = New-V1Asset -assetType Scheme -Attribute @{Name = $testScheme;SelectedValues=$schemeValues}
    $scheme = Save-V1Asset -asset $scheme
}

$scope = $scopes | Where-Object name -eq $testScope | Select -first 1
if ( -not $scope )
{
    Write-Information "Adding scope $testScope"
    $scope = New-V1Asset -assetType Scope -Attribute @{BeginDate=(Get-Date -f 'd')
                                                   Name = $testScope
                                                   Parent = $ROOT_SCOPE
                                                   Scheme = $scheme.id}
    $scope = Save-V1Asset -asset $scope
}

$doneStories = @()
$storyDefaults = @{Scope=$scope.id;Status=$DONE_STORY_STATUS}
foreach ( $i in (1..10)) 
{
    $doneStories += New-V1Asset "Story" -DefaultAttribute $storyDefaults -Attribute @{Name="${testName}_DoneStory$i"} | Save-V1Asset
} 

$doneChangeSets = @()
$storyDefaults = @{PrimaryWorkitems=($doneStories | Select id)}
foreach ( $i in (1..10)) 
{
    $doneChangeSets += New-V1Asset "ChangeSet" -DefaultAttribute $storyDefaults -Attribute @{Name="${testName}_DoneChangeSet$i"} | Save-V1Asset 
} 

$ongoingStories = @()
$storyDefaults = @{Scope=$scope.id}
foreach ( $i in (1..10)) 
{
    $ongoingStories += New-V1Asset "Story" -DefaultAttribute $storyDefaults -Attribute @{Name="${testName}_ongoingStory$i"} | Save-V1Asset
} 

$ongoingChangeSets = @()
$storyDefaults = @{PrimaryWorkitems=($ongoingStories | Select id)}
foreach ( $i in (1..10)) 
{
    $ongoingChangeSets += New-V1Asset "ChangeSet" -DefaultAttribute $storyDefaults -Attribute @{Name="${testName}_ChangeSet$i"}  | Save-V1Asset
} 

#--------------------------------------------------------------------------------------------
#---------------------------------- ASSOICATE WORKITEMS TO EPICS ----------------------------
#--------------------------------------------------------------------------------------------
Write-Progress -Activity $activityName -Status "Associating workitems to epics"

$defaultEpicProps = @{Description="Added via PS"}

$epicTypeEpic = $epics | Where-Object name -eq "${testName}_Epic"
if ( -not $epicTypeEpic  )
{
    $epicTypeEpic = New-V1Asset -assetType "Epic" -Attribute @{Name="${testName}_Epic";Scope=$scope.id;Category=$epicCategory.id} -DefaultAttribute $defaultEpicProps | Save-V1Asset 
}

$epicTypeFeature = $epics | Where-Object name -eq "${testName}_tFeature"
if ( -not $epicTypeFeature  )
{
    $epicTypeFeature = New-V1Asset -assetType "Epic" -Attribute @{Name="${testName}_Feature";Scope=$scope.id;Category=$featureCategory.id} -DefaultAttribute $defaultEpicProps | Save-V1Asset 
}

$ongoingStories | Select-Object -First 5 | Set-V1Value -Name Super -Value $epicTypeEpic.id | Save-V1Asset | Out-Null
$ongoingStories | Select-Object -Skip 5 | Set-V1Value -Name Super -Value $epicTypeFeature.id | Save-V1Asset | Out-Null


$epicTypeSubFeature = $epics | Where-Object name -eq "${testName}_SubFeature" | select -First 1
if ( -not $epicTypeSubFeature  )
{
    $epicTypeSubFeature = New-V1Asset -assetType "Epic" -Attribute @{Name="${testName}_SubFeature";Scope=$scope.id;Category=$epicCategory.id} -DefaultAttribute $defaultEpicProps| Save-V1Asset 
}

$epicTypeInitative = $epics | Where-Object name -eq "${testName}_Feature" | select -First 1
if ( -not $epicTypeInitative  )
{
    $epicTypeInitative = New-V1Asset -assetType "Epic" -Attribute @{Name="${testName}_Feature";Scope=$scope.id;Category=$featureCategory.id} -DefaultAttribute $defaultEpicProps | Save-V1Asset 
}


$doneStories | Select-Object -First 2 | Set-V1Value -Name Super -Value $epicTypeSubFeature.id | Save-V1Asset | Out-Null
$doneStories | Select-Object -Skip 5 | Set-V1Value -Name Super -Value $epicTypeInitative.id | Save-V1Asset | Out-Null


#--------------------------------------------------------------------------------------------*/
#----------------------------------- FULLY MATURED BUNDLE -----------------------------------*/
#--------------------------------------------------------------------------------------------*/
Write-Progress -Activity $activityName -Status "Associating fully matured bundles"
$MATURED_BUNDLE_PACKAGE = 'Matured Bundle Package'

$defaultBundleValues = @{PackageRevision=1;IsCustomLabel=$false}

$null = New-V1Asset -assetType Bundle -Attribute @{Name="${testName}_BundleFull";PackageReference=$MATURED_BUNDLE_PACKAGE;Phase=$developmentPhase;ChangeSets=$doneChangeSets[0..3]} -DefaultAttribute $defaultBundleValues | Save-V1Asset
$null = New-V1Asset -assetType Bundle -Attribute @{Name="${testName}_BundleFull";PackageReference=$MATURED_BUNDLE_PACKAGE;Phase=$testingPhase;ChangeSets=$doneChangeSets[0..3]} -DefaultAttribute $defaultBundleValues | Save-V1Asset
$null = New-V1Asset -assetType Bundle -Attribute @{Name="${testName}_BundleFull";PackageReference=$MATURED_BUNDLE_PACKAGE;Phase=$productionPhase;ChangeSets=$doneChangeSets[0..3]} -DefaultAttribute $defaultBundleValues | Save-V1Asset

#--------------------------------------------------------------------------------------------*/
#----------------------------------- MIXED BUNDLE -----------------------------------*/
#--------------------------------------------------------------------------------------------*/
Write-Progress -Activity $activityName -Status "Associating mixed bundles"
$MIXED_WI_STATUS_PACKAGE = 'Matured Bundle Package'

$null = New-V1Asset -assetType Bundle -Attribute @{Name="${testName}_BundleMixed";PackageReference=$MIXED_WI_STATUS_PACKAGE;Phase=$developmentPhase;ChangeSets=$doneChangeSets+$ongoingChangeSets[0..1]} -DefaultAttribute $defaultBundleValues | Save-V1Asset

#--------------------------------------------------------------------------------------------*/
#----------------------------------- ROGUE  -----------------------------------*/
#--------------------------------------------------------------------------------------------*/
Write-Progress -Activity $activityName -Status "Rogue Package"
$ROGUE_PACKAGE = 'Rogue Package'

$storyDefaults = @{Scope=$scope.id}
$null = (1..10) | ForEach-Object { New-V1Asset "Story" -DefaultAttribute $storyDefaults -Attribute @{Name="${testName}_DoneStory$_"}} | Save-V1Asset
$null = (1..10) | ForEach-Object { New-V1Asset "ChangeSet" -Attribute @{Name="ChangeSet$_"}}  | Save-V1Asset

$null = New-V1Asset -assetType Bundle -Attribute @{Name="${testName}_RogueBundle";PackageReference=$ROGUE_PACKAGE;Phase=$developmentPhase;ChangeSets=$doneChangeSets[0..3]+$ongoingChangeSets[0]} -DefaultAttribute $defaultBundleValues | Save-V1Asset
$null = New-V1Asset -assetType Bundle -Attribute @{Name="${testName}_RogueBundle";PackageReference=$ROGUE_PACKAGE;Phase=$testingPhase;ChangeSets=$doneChangeSets[0..3]+$ongoingChangeSets[0..2]} -DefaultAttribute $defaultBundleValues | Save-V1Asset
$null = New-V1Asset -assetType Bundle -Attribute @{Name="${testName}_RogueBundle";PackageReference=$ROGUE_PACKAGE;Phase=$productionPhase;ChangeSets=$doneChangeSets[3..4]+$ongoingChangeSets[3]} -DefaultAttribute $defaultBundleValues | Save-V1Asset

#--------------------------------------------------------------------------------------------
#----------------------------------- SHARED COMMIT BUNDLE -----------------------------------
#--------------------------------------------------------------------------------------------
Write-Progress -Activity $activityName -Status "Shared Commit Package"

$SHARED_COMMIT_PACKAGE = 'Shared Commit Package';

$sharedStories = (1..3) | ForEach-Object { New-V1Asset "Story" -DefaultAttribute $storyDefaults -Attribute @{Name="${testName}_SharedCommitStory$_"}} | Save-V1Asset| Out-Null
$sharedChangeSets = (1..3) | ForEach-Object { New-V1Asset "ChangeSet" -Attribute @{Name="${testName}_SharedCommitChangeSet$_";PrimaryWorkItems=$sharedStories}}  | Save-V1Asset| Out-Null

$null = New-V1Asset -assetType Bundle -Attribute @{Name="${testName}_RogueBundleShared";PackageReference=$SHARED_COMMIT_PACKAGE;Phase=$developmentPhase;ChangeSets=$sharedChangeSets} -DefaultAttribute $defaultBundleValues | Save-V1Asset


#--------------------------------------------------------------------------------------------
#----------------------------------- SPREAD COMMIT BUNDLE -----------------------------------
#--------------------------------------------------------------------------------------------
Write-Progress -Activity $activityName -Status "Spread Commit Package"

$SPREAD_COMMIT_PACKAGE = 'Shared Commit Package';

$spreadStories = (1..6) | ForEach-Object { New-V1Asset "Story" -DefaultAttribute $storyDefaults -Attribute @{Name="${testName}_SharedCommitStory$_"}} | Save-V1Asset
$spreadChangeSets = (1..6) | ForEach-Object { New-V1Asset "ChangeSet" -Attribute @{Name="${testName}_SpreadSharedCommitChangeSet$_";PrimaryWorkItems=$spreadStories[0]}}  | Save-V1Asset

$null = New-V1Asset -assetType Bundle -Attribute @{Name="${testName}_RogueBundleSpread";PackageReference=$SPREAD_COMMIT_PACKAGE;Phase=$developmentPhase;ChangeSets=$spreadChangeSets[0..1]} -DefaultAttribute $defaultBundleValues | Save-V1Asset
$null = New-V1Asset -assetType Bundle -Attribute @{Name="${testName}_RogueBundleSpread";PackageReference=$SPREAD_COMMIT_PACKAGE;Phase=$testingPhase;ChangeSets=$spreadChangeSets[2..3]} -DefaultAttribute $defaultBundleValues | Save-V1Asset
$null = New-V1Asset -assetType Bundle -Attribute @{Name="${testName}_RogueBundleSpread";PackageReference=$SPREAD_COMMIT_PACKAGE;Phase=$productionPhase;ChangeSets=$spreadChangeSets[4..5]} -DefaultAttribute $defaultBundleValues | Save-V1Asset


}
catch
{
    Write-Error "Exception!`n$_`n$($_.ScriptStackTrace)"
}