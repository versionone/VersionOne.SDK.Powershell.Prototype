function Get-V1AssetTypeValue
{
param( 
[Parameter(Mandatory)]    
[string] $assetType, 
[switch] $dontThrowIfNotExists,
[switch] $required, 
[switch] $alsoReadOnly )

    Set-StrictMode -Version Latest

    $ret = Get-V1AssetType -assetType $assetType
    if ( $required )
    {
        return $ret.values | Where-Object IsRequired -eq $true
    }
    elseif ( $alsoReadOnly )
    {
        return $ret.values
    }
    else
    {
        return $ret.values | Where-Object IsReadOnly -eq $false 
    }
}

