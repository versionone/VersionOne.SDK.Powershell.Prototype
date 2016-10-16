try
{

ipmo (Join-path $PSScriptRoot V1.psm1) -Force
cls

$error.Clear()
$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"

Set-V1Default -baseUri "localhost/VersionOne.Web" -token "1.bxDPFh/9y3x9MAOt469q2SnGDqo="

$activityName = "Add Daag data"

Write-Progress -Activity $activityName -Status "Initializing"

# load meta 
$null = Get-V1Meta

Write-Progress -Activity $activityName -Status "Loading scopes"
$scopes = Get-V1Asset -assetType "Scope" -properties "Name"

Write-Progress -Activity $activityName -Status "Loading schemes"
$schemes = Get-V1Asset -assetType "Scheme" -properties "Name"

Write-Progress -Activity $activityName -Status "Loading phases"
$phases = Get-V1Asset -assetType "Phase" -properties "Name"

Write-Progress -Activity $activityName -Status "Loading epic categories"
$epicCategories = Get-V1Asset -assetType "EpicCategory" -properties "Name"

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

$testScheme = "PSValveScheme3"
$testScope = "PSValveScope"

# constants
$OID_NULL = 'NULL'
$ROOT_SCOPE = 'Scope:0'
$DONE_STORY_STATUS = 'StoryStatus:135'
$ADMIN_ROLE = 'Role:1'

$scheme = $Schemes | Where-Object name -eq $testScheme | Select -first 1
if ( -not $scheme )
{
    Write-Information "Adding Scheme $testScheme"
    $schemeValues = $DONE_STORY_STATUS,$developmentPhase,$testingPhase,$productionPhase,$epicCategory,$featureCategory,$subFeatureCategory,$initiativeCategory
    $scheme = New-V1Asset -assetType Scheme -asset @{Name = $testScheme;SelectedValues=$schemeValues}
    $scheme = Save-V1Asset -asset $scheme
}

$scope = $scopes | Where-Object name -eq $testScope | Select -first 1
if ( -not $scope )
{
    Write-Information "Adding scope $testScope"
    $scope = New-V1Asset -assetType Scope -asset @{BeginDate=(Get-Date -f 'd')
                                                   Name = $testScope
                                                   Parent = "Scope:0"
                                                   Scheme = $scheme.id}
    $scope = Save-V1Asset -asset $scope
}


$doneStories = @()
$storyDefaults = @{Scope=$scope.id;Status=$DONE_STORY_STATUS}
foreach ( $i in (1..5)) 
{
    $doneStories += Save-V1Asset (New-V1Asset "Story" -defaultvalues $storyDefaults -asset @{Name="DoneStory$i"})
} 

$doneChangeSets = @()
$storyDefaults = @{PrimaryWorkitems=($doneStories | Select id)}
foreach ( $i in (1..5)) 
{
    $doneChangeSets += Save-V1Asset (New-V1Asset "ChangeSet" -defaultvalues $storyDefaults -asset @{Name="DoneChangeSet$i"})
} 


$ongoingStories = @()
$storyDefaults = @{Scope=$scope.id}
foreach ( $i in (1..5)) 
{
    $ongoingStories += Save-V1Asset (New-V1Asset "Story" -defaultvalues $storyDefaults -asset @{Name="ongoingStory$i"})
} 

$ongoingChangeSets = @()
$storyDefaults = @{PrimaryWorkitems=($ongoingStories | Select id)}
foreach ( $i in (1..5)) 
{
    $ongoingChangeSets += Save-V1Asset (New-V1Asset "ChangeSet" -defaultvalues $storyDefaults -asset @{Name="ChangeSet$i"})
} 

#--------------------------------------------------------------------------------------------
#---------------------------------- ASSOICATE WORKITEMS TO EPICS ----------------------------
#--------------------------------------------------------------------------------------------
Write-Progress -Activity $activityName -Status "Associating workitems to epics"


$defaultEpicProps = @{Description="Added via PS"}

$epicTypeEpic = $epics | Where-Object name -eq "PSTestEpic"
if ( -not $epicTypeEpic  )
{
    $epicTypeEpic = Save-V1Asset (New-V1Asset -assetType "Epic" -asset @{Name="PSTestEpic";Scope=$scope.id;Category=$epicCategory.id} -defaultvalues $defaultEpicProps)
}

$epicTypeFeature = $epics | Where-Object name -eq "PSTestFeature"
if ( -not $epicTypeFeature  )
{
    $epicTypeFeature = Save-V1Asset (New-V1Asset -assetType "Epic" -asset @{Name="PSTestFeature";Scope=$scope.id;Category=$featureCategory.id} -defaultvalues $defaultEpicProps)
}

function Set-V1Value
{
param( 
[Parameter(Mandatory,ValueFromPipeline)]
$asset, 
$name, 
$value )

process
{
    Set-StrictMode -Version Latest

    if ( -not (Get-Member -Input $asset -name $name ))
    {
        Add-Member -InputObject $asset -MemberType NoteProperty -Name $name -Value $value
    }
    else
    {
        $asset.$name = $value
    }
    return $asset
}
}

$ongoingStories | Select-Object -First 5 | Set-V1Value -Name Super -Value $epicTypeEpic.id | Save-V1Asset 


$ongoingStories | Select-Object -Skip 5 | Set-V1Value -Name Super -Value $epicTypeFeature.id | Save-V1Asset 



}
catch
{
    Write-Error "Exception!`n$_`n$($_.ScriptStackTrace)"
}