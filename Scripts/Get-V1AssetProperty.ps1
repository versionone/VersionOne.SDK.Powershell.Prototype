function Get-V1AssetProperty
{
param(
[Parameter(Mandatory)]
[object] $asset,
[Parameter(Mandatory)]
[string] $name)

    Set-StrictMode -Version Latest
    if ( -not (Get-Member -InputObject $asset -Name "AssetType"))
    {
        throw "Must supply object with AssetType property"
    }

    $assetMeta = (Get-V1Meta)[$asset.AssetType]
    if ( $assetMeta )
    {
        return $assetMeta[$name] 
    }
    else
    {
        throw "AssetType of name '$assetType' not found in meta"
    }
    
}
