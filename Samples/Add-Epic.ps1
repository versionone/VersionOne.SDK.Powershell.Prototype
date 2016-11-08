<#
Add a scope, schemes and Epics
#>
[CmdletBinding()]
param(
[string] $testName = "PSTest", # name used for all names,
[string] $baseUri = "localhost/VersionOne.Web",
[string] $token = "1.bxDPFh/9y3x9MAOt469q2SnGDqo=",
[int] $epicCount = 10
)

try 
{

cls

Set-StrictMode -Version Latest
$error.Clear()
$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"


Import-Module (Join-path $PSScriptRoot "..\V1.psm1") -Force
Set-V1Connection -baseUri $baseUri -token $token
$null = Get-V1Meta

# load common base assets
$scopes = Get-V1Asset -assetType "Scope" -attributes "Name"
$schemes = Get-V1Asset -assetType "Scheme" -attributes "Name"
$epicCategories = Get-V1Asset -assetType "EpicCategory" -attributes "Name"
$epics = Get-V1Asset -assetType "Epic"

# add scheme if not exists
$testScheme = "${testName}Scheme1"
$scheme = $Schemes | Where-Object name -eq $testScheme | Select -first 1
if ( -not $scheme )
{
    Write-Information "Adding Scheme $testScheme"
    $scheme = New-V1Asset -assetType Scheme -attributes @{Name = $testScheme}
    $scheme = Save-V1Asset -asset $scheme 
}

# add scope if not exists
$testScope = "${testName}Scope1"
$scope = $scopes | Where-Object name -eq $testScope | Select -first 1
if ( -not $scope )
{
    Write-Information "Adding scope $testScope"
    $scope = New-V1Asset -assetType Scope -attributes @{BeginDate=(Get-Date -f 'd')
                                                   Name = $testScope
                                                   Parent = "Scope:0"
                                                   Scheme = $scheme.id}
    $scope = Save-V1Asset -asset $scope 
}

# add epicCount epics 
$defaultEpicProps = @{Description="Added via PS"}
$newEpics = @()
foreach ( $i in (1..$epicCount) )
{
    if ( -not ($epics | Where-Object name -eq "${testName}Epic$i") )
    {
        Write-Information "Adding Epic ${testName}Epic$i"
        $epic = New-V1Asset -assetType "Epic" -attributes @{Name="${testName}Epic$i";Scope=$scope.id} -defaultAttributes $defaultEpicProps
        
        $newEpics += Save-V1Asset $epic
    }

}

$newEpics | Out-GridView

}
catch
{
    Write-Error "Exception!`n$_`n$($_.ScriptStackTrace)"
}