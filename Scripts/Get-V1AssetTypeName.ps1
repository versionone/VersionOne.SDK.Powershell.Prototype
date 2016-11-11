<#
.Synopsis
	Get the correct case of an asset type name
	
.Parameter AssetType
	asset type name

.Parameter DontThrowIfNotFound
	if set won't throw if not found

.Outputs
	the AssetType name in the correct case

#>
function Get-V1AssetTypeName
{
param(
[Parameter(Mandatory)]
[string] $AssetType,
[switch] $DontThrowIfNotFound    
)
    
    $key = Get-V1MetaName | Where-Object { $_ -eq $assetType }
    if ( -not $key -and (-not $DontThrowIfNotFound) )
    {
        throw "AssetType of '$AssetType' not found in meta"
    }
    $key
}