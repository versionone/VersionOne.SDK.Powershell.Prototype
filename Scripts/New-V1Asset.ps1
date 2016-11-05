<#
.Synopsis
	Create a new V1 Asset of the given type
	
.Parameter AssetType
	The type of the asset, use (Get-V1Meta).Keys | sort to see all valid values

.Parameter attributes
	Initial attributes for the asset.  They must be valid and include all required ones.  To see them, use Get-V1MetaAttribute -assetType Epic -required | select name,attributeType

.Parameter DefaultAttributes
	Optional addition attributes to set.

.Parameter Full
	if set will populate the object with all the possible writable attributes for the asset

.Outputs
	a PSCustomObject

#>
function New-V1Asset
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]
[string] $AssetType,
[Parameter(ValueFromPipeline)]
[hashtable] $Attributes = @{},
[ValidateNotNull()]
[hashtable] $DefaultAttributes = @{},
[switch] $AddMissingRequired,
[switch] $Full
)

process
{
    Set-StrictMode -Version Latest

    $assetMeta = Get-V1Meta -assetType $AssetType

    $ht = @{AssetType=$AssetType}+$Attributes+$DefaultAttributes

    $ret = [PSCustomObject]$ht
    
    if ( $Full )
    {
        $missingWritable = $assetMeta.Keys | Where-Object { -not $assetMeta[$_].IsReadOnly } | Where-Object { $_ -notin $ht.Keys }
        $missingWritable | ForEach-Object { Set-V1Value $ret -Name $_ -Value $null } | Out-Null
    }
    else
    {    
        $missingRequired =  $assetMeta.Keys | Where-Object { $assetMeta[$_].IsRequired } | Where-Object { $_ -notin $ht.Keys }

        if ( $missingRequired )
        {
            if ( -not $Attributes -or $AddMissingRequired )
            {
                $missingRequired | ForEach-Object { Set-V1Value $ret -Name $_ -Value $null } | Out-Null
                Write-Warning "For asset of type $($AssetType), added missing attributes: $($missingRequired -join ", ")"
            }
            else 
            {
                throw "Asset of type $($AssetType) requires missing attributes: $($missingRequired -join ", ")"        
            }
        }
    }
     
    return $ret
}

}

Set-Alias -Name v1new New-V1Asset