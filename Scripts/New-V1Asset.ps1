<#
.Synopsis
	Create a new V1 Asset of the given type
	
.Parameter assetType
	The type of the asset, use (Get-V1Meta).Keys | sort to see all valid values

.Parameter attributes
	Initial attributes for the asset.  They must be valid and include all required ones.  To see them, use Get-V1AssetType -assetType Epic -required | select name,attributeType

.Parameter defaultAttributes
	Optional addition attributes to set.

.Parameter full
	if set will populate the object with all the possible writable attributes for the asset

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
[hashtable] $attributes,
[ValidateNotNull()]
[hashtable] $defaultAttributes = @{},
[switch] $addMissingRequired,
[switch] $full
)

process
{
    Set-StrictMode -Version Latest

    $assetMeta = Get-V1AssetTypeMeta -assetType $assetType

    $ret = @{AssetType=$assetType}+$attributes+$defaultAttributes
    
    $missingRequired =  $assetMeta.Keys | Where-Object { $assetMeta[$_].IsRequired } | Where-Object { $_ -notin $ret.Keys }
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
        # add All writable attributes
        Write-Warning "TODO"
    }

    return $ret
}

}

