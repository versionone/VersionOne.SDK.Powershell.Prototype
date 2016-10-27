<#
.Synopsis
	Get the the attributes for a V1 AssetType
	
.Parameter assetType
	the name of the asset type to show

.Parameter dontThrowIfNotExists
	throw an exception if the asset type doesn't exist in meta.  Otherwise returns $null

.Parameter required
	only return the required attributes

.Parameter alsoReadOnly
	also return the read-only attributes.  Otherwise only returns writable attributes.

.Outputs
	array of hash tables of attribute data

.Example
     Get-V1AssetType Epic | ft

     Get the Epic's attributes and format them in a table

.Example
     Get-V1AssetType Story -also | sort name | ft

     Get all the Story's attributes (including read-only) sorte by name and format them in a table     
#>
function Get-V1AssetType
{
param( 
[Parameter(Mandatory)]    
[string] $assetType, 
[switch] $dontThrowIfNotExists,
[switch] $required, 
[switch] $alsoReadOnly )

    Set-StrictMode -Version Latest

    $ret = Get-V1AssetTypeMeta -assetType $assetType
    if ( $required )
    {
        return $ret.values | Where-Object IsRequired -eq $true
    }
    elseif ( $alsoReadOnly )
    {
        return $ret.values
    }
    else
    {
        return $ret.values | Where-Object IsReadOnly -eq $false 
    }
}

