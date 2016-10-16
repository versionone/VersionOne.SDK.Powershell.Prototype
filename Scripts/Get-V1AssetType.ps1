function Get-V1AssetType
{
param( 
[Parameter(Mandatory)]    
[string] $assetType, 
[switch] $dontThrowIfNotExists, 
[switch] $alsoReadOnly,
[string] $baseUri )

    Set-StrictMode -Version Latest

    $meta = Get-V1Meta $baseUri
    $ret = $meta[$assetType]
    if (-not $ret -and -not $dontThrowIfNotExists)  
    {
        throw  "Asset type of $AssetType not found in meta"    
    }
    return $ret
}

