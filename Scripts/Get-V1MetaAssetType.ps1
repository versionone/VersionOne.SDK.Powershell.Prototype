<#
.Synopsis
	Get the the attributes for a V1 AssetType
	
.Parameter AssetType
	The name of the asset type to show

.Parameter ThrowIfNotExists
	Throw an exception if the asset type doesn't exist in meta.  Otherwise returns $null

.Parameter Required
	Only return the required attributes

.Parameter AlsoReadOnly
	Also return the read-only attributes.  Otherwise only returns writable attributes.

.Outputs
	Array of hash tables of attribute data

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
[string] $AssetType, 
[switch] $ThrowIfNotExists,
[switch] $Required, 
[switch] $AlsoReadOnly )

    Set-StrictMode -Version Latest

    $attrs = Get-V1Meta -assetType $AssetType
    if (-not $AssetType -and -not $ThrowIfNotExists)  
    {
        throw  "Asset type of $AssetType not found in meta"    
    }    

    if ( $Required )
    {
        $ret = $attrs.values | Where-Object IsRequired -eq $true
    }
    elseif ( $AlsoReadOnly )
    {
        $ret = $attrs.values
    }
    else
    {
        $ret = $attrs.values | Where-Object IsReadOnly -eq $false 
    }
    $ret
}

New-Alias -Name v1asset -Value Get-V1MetaAssetType