<#
.Synopsis
	Gets an object that can be used in a Get-V1Asset and Get-V1AssetPaged -filter to tab-complete values
	
.Parameter AssetType
	The name of the asset type to show

.Parameter Required
	Only return the required attributes

.Parameter AlsoReadOnly
	Also return the read-only attributes.  Otherwise only returns writable attributes.

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
[string] $AssetType, 
[switch] $Required, 
[switch] $AlsoReadOnly )

    $ht = @{}
    Get-V1MetaAssetType -assetType $AssetType -required:$Required -alsoReadOnly:$AlsoReadOnly -throwIfNotExists | ForEach-Object { $ht[$_.Name] = $null }

    [PSCustomObject]$ht
}

New-Alias -Name v1filter Get-V1FilterAsset