<#
.Synopsis
	Get the details about an V1 asset's attribute from meta
	
.Description
    This is use in conversion functions
    
.Parameter asset
	the asset object

.Parameter name
	the name of the attribute on the asset

.Outputs
	hash table of attribute meta data

.Example
    $x = Get-V1Asset -assetType EpicCategory
    Get-V1MetaAttribute $x[0] ColorName

    Show the details about the ColorName attribute on the EpicCategory AssetType
#>
function Get-V1MetaAttribute
{
param(
[Parameter(Mandatory)]
[object] $asset,
[Parameter(Mandatory)]
[string] $name)

    Set-StrictMode -Version Latest
    if ( -not (Get-Member -InputObject $asset -Name "AssetType"))
    {
        throw "Must supply object with AssetType attribute"
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
