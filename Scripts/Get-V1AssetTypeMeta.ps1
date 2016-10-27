<#
.Synopsis
    Get the attributes for an asset type as a hash table

.Description
    Used by many of the PS SDK functions

.Parameter assetType
	the name of the asset type to show

.Parameter dontThrowIfNotExists
	throw an exception if the asset type doesn't exist in meta.  Otherwise returns $null

.Parameter alsoReadOnly
	also return the read-only attributes.  Otherwise only returns writable attributes.

.Outputs
	hash table of hash tables of attribute data

#>
function Get-V1AssetTypeMeta
{
param( 
[Parameter(Mandatory)]    
[string] $assetType, 
[switch] $dontThrowIfNotExists, 
[switch] $alsoReadOnly)

    Set-StrictMode -Version Latest

    $meta = Get-V1Meta
    $ret = $meta[$assetType]
    if (-not $ret -and -not $dontThrowIfNotExists)  
    {
        throw  "Asset type of $AssetType not found in meta"    
    }
    return $ret
}

