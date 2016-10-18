<#
.Synopsis
    Given an object from the API, convert it into a friendlier PS object
#>
function ConvertFrom-V1Xml
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]
[ValidateScript({ (Get-Member -InputObject $_ -Name Asset) -and (Get-Member -InputObject $_.Asset -Name Attribute) -and (Get-Member -InputObject $_.Asset -Name Relation) })]
$assetXml
)
    Set-StrictMode -Version Latest

    $asset = $assetXml.Asset
    $assetType =  ($asset.Attribute | Where-Object name -eq 'AssetType' ).'#text'

    $ret = @{}
    foreach ( $a in $asset.Attribute | Where-Object name -NotLike "*.*" )
    {
        Write-Verbose "Converting $($assetType).$($a.name)"
        if ( Get-Member -InputObject $a -Name "#text" )
        {
            $ret[$a.name] = ConvertFrom-V1MetaString $assetType $a.name $a.'#text'
        }
        else
        {
            $ret[$a.name] = ""
        }
    }

    foreach ( $a in $asset.Relation )
    {
        if ( $a | Get-Member Asset )
        {
            $ret[$a.name] = $a.Asset.idRef
        } 
        else
        {
            $ret[$a.name] = $null
        } 
    }
    return [PSCustomObject]$ret
}
