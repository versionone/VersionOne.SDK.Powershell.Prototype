function New-V1Asset
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]
[string] $assetType,
[Parameter(Mandatory,ValueFromPipeline)]
[hashtable] $asset,
[hashtable] $defaultvalues = @{}
)

    switch ($assetType)
    {
        "Epic"  { 
            return [PSCustomObject](@{AssetType=$assetType}+$asset+$defaultvalues)
        }
        "Scope" {
            return [PSCustomObject](@{AssetType=$assetType}+$asset+$defaultvalues)
        }
        "Scheme" {
            return [PSCustomObject](@{AssetType=$assetType}+$asset+$defaultvalues)
        }
        default {
            throw "Unsupported assetType of $assetType"
        }
    }
}

