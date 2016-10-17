function New-V1Asset
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]
[string] $assetType,
[Parameter(Mandatory,ValueFromPipeline)]
[hashtable] $asset,
[ValidateNotNull()]
[hashtable] $defaultValues = @{},
[switch] $full
)

process
{
    Set-StrictMode -Version Latest

    $assetMeta = Get-V1AssetType -assetType $assetType

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

}