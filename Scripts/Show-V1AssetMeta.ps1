function Show-V1AssetMeta
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]
[string] $assetType,
[switch] $full,
[Parameter(Mandatory)]    
[string] $baseUri
)
    Set-StrictMode -Version Latest

    $assetMeta = Get-V1AssetType -assetType $assetType -baseUri $baseUri

    $assetMeta.values  
}    