<#
Add a scope, schemes and Epics
#>
[CmdletBinding()]
param(
[string] $testName = "PSTest", # name used for all names,
[string] $baseUri = "localhost/VersionOne.Web",
[System.Management.Automation.CredentialAttribute()]
[PSCredential] $Credential,
[string] $token,
[int] $epicCount = 10
)

$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"

. (Join-Path $PSScriptRoot Push-V1Asset.ps1)
. (Join-Path $PSScriptRoot New-V1TestName.ps1)

try 
{

Set-StrictMode -Version Latest
$error.Clear()


Import-Module (Join-path $PSScriptRoot "..\V1.psm1") -Force
$null = Set-V1Connection -baseUri $baseUri -token $token -cred $Credential -test
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
$defaultEpicProps = @{Description="Added via PS";Scope=$scope.id}

$epics = New-V1TestName $epicCount -prefix "${testName}Epic" | New-V1Asset -assetType "Epic" -Name Name `
            -defaultAttributes $defaultEpicProps | Push-V1Asset  

$epics | Select id,name,description | Format-Table -AutoSize

}
catch
{
    Write-Error "Exception!`n$_`n$($_.ScriptStackTrace)"
}