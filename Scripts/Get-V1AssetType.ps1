function Get-V1AssetType
{
param( 
[Parameter(Mandatory)]    
[string] $assetType, 
[switch] $dontThrowIfNotExists, 
[switch] $alsoReadOnly)

    Set-StrictMode -Version Latest

    $meta = Get-V1Meta
    $ret = $meta[$assetType]
    if (-not $ret -and -not $dontThrowIfNotExists)  
    {
        throw  "Asset type of $AssetType not found in meta"    
    }
    return $ret
}

