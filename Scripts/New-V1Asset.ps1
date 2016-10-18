<#
.Synopsis
	Create a new V1 Asset of the given type
	
.Parameter assetType
	The type of the asset, use (Get-V1Meta).Keys | sort to see all valid values

.Parameter properties
	Initial properties for the asset.  They must be valid and include all required ones.  To see them, use Get-V1AssetTypeValue -assetType Epic -required | select name,attributeType

.Parameter defaultProperties
	Optional addition properties to set.

.Parameter full
	if set will populate the object with all the possible writable properties for the asset

.Outputs
	a PSCustomObject

#>
function New-V1Asset
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]
[string] $assetType,
[Parameter(Mandatory,ValueFromPipeline)]
[hashtable] $properties,
[ValidateNotNull()]
[hashtable] $defaultProperties = @{},
[switch] $addMissingRequired,
[switch] $full
)

process
{
    Set-StrictMode -Version Latest

    $assetMeta = Get-V1AssetType -assetType $assetType

    $ret = @{AssetType=$assetType}+$properties+$defaultProperties
    
    $missingRequired =  $assetMeta.Keys | Where-Object { $assetMeta[$_].IsRequired } | Where { $_ -notin $ret.Keys }
    $ret = [PSCustomObject]$ret

    if ( $missingRequired )
    {
        if ( $addMissingRequired )
        {
            $missingRequired | ForEach-Object { Set-V1Value $ret -Name $_ -Value $null } | Out-Null
            Write-Warning "For asset of type $($assetType), added missing attributes: $($missingRequired -join ", ")"
        }
        else 
        {
            throw "Asset of type $($assetType) requires missing attributes: $($missingRequired -join ", ")"        
        }
    }
     
    if ( $full )
    {
        # add All writable properties
        Write-Warning "TODO"
    }

    return $ret
}

}
