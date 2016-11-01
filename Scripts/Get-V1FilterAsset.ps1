<#
.Synopsis
	Gets an object that can be used in a Get-V1Asset and Get-V1AssetPaged -filter to tab-complete values
	
.Parameter assetType
	the name of the asset type to show

.Parameter required
	only return the required attributes

.Parameter alsoReadOnly
	also return the read-only attributes.  Otherwise only returns writable attributes.

.Outputs
	Object that can be used in a filter parameter on Get-V1Asset

.Example
     Get-V1FilterAsset Epic

     Get the Epic's seach object and searches on them

#>
function Get-V1FilterAsset
{
param( 
[Parameter(Mandatory)]    
[string] $assetType, 
[switch] $required, 
[switch] $alsoReadOnly )

    $ht = @{}
    Get-V1MetaAssetType -assetType $assetType -required:$required -alsoReadOnly:$alsoReadOnly -throwIfNotExists | ForEach-Object { $ht[$_.Name] = $null }

    [PSCustomObject]$ht
}
