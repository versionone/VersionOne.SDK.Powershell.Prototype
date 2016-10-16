function New-V1Asset
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]
[string] $assetType,
[Parameter(Mandatory,ValueFromPipeline)]
[hashtable] $asset,
[hashtable] $defaultvalues = @{},
[switch] $full,
[Parameter(Mandatory)]    
[string] $baseUri
)
    Set-StrictMode -Version Latest

    $assetMeta = Get-V1AssetType -assetType $assetType -baseUri $baseUri

    $ret = @{AssetType=$assetType}+$asset+$defaultValues
    
    $missingRequired =  $assetMeta.Keys | Where-Object { $assetMeta[$_].IsRequired } | Where { $_ -notin $ret.Keys }
    if ( $missingRequired )
    {
        throw "Asset of type $($assetType) requires missing attributes: $($missingRequired -join ", ")"
    }
     
    if ( $full )
    {
        # add All writable properties
        Write-Warning "TODO"
    }

    return [PSCustomObject]$ret
}

