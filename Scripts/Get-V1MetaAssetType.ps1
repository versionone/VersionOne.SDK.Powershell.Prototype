<#
.Synopsis
	Get the the attributes for a V1 AssetType
	
.Parameter assetType
	the name of the asset type to show

.Parameter throwIfNotExists
	throw an exception if the asset type doesn't exist in meta.  Otherwise returns $null

.Parameter required
	only return the required attributes

.Parameter alsoReadOnly
	also return the read-only attributes.  Otherwise only returns writable attributes.

.Outputs
	array of hash tables of attribute data

.Example
     Get-V1MetaAttribute Epic | ft

     Get the Epic's attributes and format them in a table

.Example
     Get-V1MetaAttribute Story -also | sort name | ft

     Get all the Story's attributes (including read-only) sorte by name and format them in a table     
#>
function Get-V1MetaAssetType
{
param( 
[Parameter(Mandatory)]    
[string] $assetType, 
[switch] $throwIfNotExists,
[switch] $required, 
[switch] $alsoReadOnly )

    Set-StrictMode -Version Latest

    $attrs = Get-V1Meta -assetType $assetType
    if (-not $assetType -and -not $throwIfNotExists)  
    {
        throw  "Asset type of $AssetType not found in meta"    
    }    

    if ( $required )
    {
        $ret = $attrs.values | Where-Object IsRequired -eq $true
    }
    elseif ( $alsoReadOnly )
    {
        $ret = $attrs.values
    }
    else
    {
        $ret = $attrs.values | Where-Object IsReadOnly -eq $false 
    }
    $ret
}
