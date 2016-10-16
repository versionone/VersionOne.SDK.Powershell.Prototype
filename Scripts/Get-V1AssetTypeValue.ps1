function Get-V1AssetTypeValue
{
param( 
[Parameter(Mandatory)]    
[string] $assetType, 
[switch] $dontThrowIfNotExists, 
[switch] $alsoReadOnly,
[string] $baseUri )

    Set-StrictMode -Version Latest

    $ret = Get-V1AssetType -assetType $assetType -baseUri $baseUri
    if ( $alsoReadOnly )
    {
        return $ret.values
    }
    else
    {
        return $ret.values | Where-Object IsReadOnly -eq false 
    }
}

