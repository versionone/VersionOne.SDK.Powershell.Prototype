ipmo (Join-path $PSScriptRoot "..\V1.psm1") -Force

cls

$error.Clear()
$ErrorActionPreference = "Stop"

Set-V1Default -baseUri "localhost/VersionOne.Web" -token "1.bxDPFh/9y3x9MAOt469q2SnGDqo="

$null = Get-V1Meta

$scopes = Get-V1Asset -assetType "Scope" -properties "Name"

$schemes = Get-V1Asset -assetType "Scheme" -properties "Name"

$epicCategories = Get-V1Asset -assetType "EpicCategory" -properties "Name"

$epics = Get-V1Asset -assetType "Epic"

$testScheme = "PSTestScheme1"
$testScope = "PSTestScope1"

$scheme = $Schemes | Where-Object name -eq $testScheme | Select -first 1
if ( -not $scheme )
{
    Write-Information "Adding Scheme $testScheme"
    $scheme = New-V1Asset -assetType Scheme -properties @{Name = $testScheme}
    $scheme = Save-V1Asset -asset $scheme 
}

$scope = $scopes | Where-Object name -eq $testScope | Select -first 1
if ( -not $scope )
{
    Write-Information "Adding scope $testScope"
    $scope = New-V1Asset -assetType Scope -properties @{BeginDate=(Get-Date -f 'd')
                                                   Name = $testScope
                                                   Parent = "Scope:0"
                                                   Scheme = $scheme.id}
    $scope = Save-V1Asset -asset $scope 
}

$defaultEpicProps = @{Description="Added via PS"}

$newEpics = @()

foreach ( $i in (1..10) )
{
    if ( -not ($epics | Where-Object name -eq "PSTestEpic$i") )
    {
        Write-Information "Adding Epic PSTestEpic$i"
        $epic = New-V1Asset -assetType "Epic" -properties @{Name="PSTestEpic$i";Scope=$scope.id} -defaultproperties $defaultEpicProps
        
        $newEpics += Save-V1Asset $epic
    }

}


   $scope = New-V1Asset -assetType Scope -properties @{BeginDate=(Get-Date -f 'd')
                                                   Name = $testScope
                                                   Parent = "Scope:0"
                                                   Scheme = $scheme.id
                                                   }
    $scope = Save-V1Asset -asset $scope -WhatIf -Verbose

$newEpics | Out-GridView
