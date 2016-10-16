. .\ConvertFrom-V1Json.ps1
. .\ConvertTo-V1Json.ps1
. .\Get-V1Asset.ps1
. .\New-V1Asset.ps1
. .\Save-V1Asset.ps1

$error.Clear()
$ErrorActionPreference = "Stop"


$scopes = (Get-V1Asset -assetType "Scope" -properties "Name" -Verbose)

$schemes = (Get-V1Asset -assetType "Scheme" -properties "Name" -Verbose)

$epicCategories = (Get-V1Asset -assetType "EpicCategory" -properties "Name" -Verbose)

$epics = (Get-V1Asset -assetType "Epic")

$testScheme = "JimTestScheme"
$testScope = "JimTestScope"

$scheme = $Schemes | Where-Object name -eq $testScheme | Select -first 1
if ( -not $scheme )
{
    Write-Information "Adding Scheme $testScheme"
    $scheme = New-V1Asset -assetType Scheme -asset @{Name = $testScheme}
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

$defaultEpicProps = @{Description="Added via PS"}

$newEpics = @()

foreach ( $i in (1..5) )
{
    if ( -not ($epics | Where-Object name -eq "PSTestEpic$i") )
    {
        $epic = New-V1Asset -assetType "Epic" -asset @{Name="PSTestEpic$i";Scope=$scope.id} -defaultvalues $defaultEpicProps
        
        $newEpics += Save-V1Asset $epic
    }

}

$newEpics | Out-GridView

# $e = ConvertFrom-Json (gc C:\temp\meta.json -Raw) 