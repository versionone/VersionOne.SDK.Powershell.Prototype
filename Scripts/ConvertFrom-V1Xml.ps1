function getXmlValue
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]
[string] $assetType,
[Parameter(Mandatory)]
[string] $attributeName,
[string] $attributeValue
)
    $meta = Get-V1Meta

    $assetMeta = $meta[$assetType]
    if ( $assetMeta )
    {
        if ( $attributeValue -eq $null )
        {
            return null;
        }

        $attrDef = $assetMeta.AssetType.AttributeDefinition | Where-Object name -eq $attributeName;

        if ( $attrDef )
        {

            switch( $attrDef.attributetype )
            {
                "Date" { return [DateTime]::Parse($attributeValue); }
                "Numeric" { return [Decimal]::Parse($attributeValue); }
                "Text" { return $attributeValue; }
                "Relation" { return $attributeValue; }
                "AssetType" { return $attributeValue; }
                "Opaque" { return $attributeValue; }
                "Boolean" { return [Bool]::Parse($attributeValue); }
                "LongText" { return $attributeValue; }
                "State" { return $attributeValue; }
                "LongInt" { return [Int64]::Parse($attributeValue); }
                "Rank" { return $attributeValue; }
                "Duration" { return $attributeValue; }
                "Blob" { return $attributeValue; }
                "Guid" { return [Guid]::Parse($attributeValue); }
                "Password" { return $attributeValue; }
                "LocalizerTag" { $attributeValue; }            
                default { return $null }
            }
        }
        else
        {
            throw "AssetType '$assetType' does not have attribute of '$attributeName'"
        }
    }
    else
    {
        throw "AssetType of name '$assetType' not found in meta"
    }
}

<#
.Synopsis
    Given an object from the API, convert it into a friendlier PS object
	
.Parameter assetXml
	the XML returned from Invoke-RestMethod 

.Outputs
	an object hydrated from JSON

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
            $ret[$a.name] = getXmlValue $assetType $a.name $a.'#text'
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
