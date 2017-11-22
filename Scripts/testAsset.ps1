function testAsset
{
param(
[Parameter(Mandatory)]
$Asset,
[switch] $IdRequired
)
    if ( -not $Asset -or 
        -not (Get-Member -input $Asset -Name AssetType) -or
        -not $Asset.AssetType )
    {
        throw "Asset parameter must be not null and have AssetType"
    }

    if ( $IdRequired -and 
        (-not (Get-Member -input $Asset -Name ID) -or
         -not $Asset.ID))
    {
        throw "Asset parameter must have AssetType and ID"
    }
}