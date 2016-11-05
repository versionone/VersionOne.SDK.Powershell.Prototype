<#
.Synopsis
	Get the details about an V1 asset's attribute from meta
	
.Description
    This is use in conversion functions
    
.Parameter Asset
	The asset object

.Parameter Name
	The name of the attribute on the asset

.Outputs
	Hash table of attribute meta data

.Example
    $x = Get-V1Asset -assetType EpicCategory
    Get-V1MetaAttribute $x[0] ColorName

    Show the details about the ColorName attribute on the EpicCategory AssetType
#>
function Get-V1MetaAttribute
{
param(
[Parameter(Mandatory)]
[object] $Asset,
[Parameter(Mandatory)]
[string] $Name)

    Set-StrictMode -Version Latest
    if ( -not (Get-Member -InputObject $Asset -Name "AssetType"))
    {
        throw "Must supply object with AssetType attribute"
    }

    $AssetMeta = (Get-V1Meta)[$Asset.AssetType]
    if ( $AssetMeta )
    {
        return $AssetMeta[$Name] 
    }
    else
    {
        throw "AssetType of name '$AssetType' not found in meta"
    }
    
}
