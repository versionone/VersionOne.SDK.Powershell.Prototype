function getXmlValue
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]
[string] $AssetType,
[Parameter(Mandatory)]
[string] $AttributeName,
[string] $AttributeValue
)
    $meta = Get-V1Meta

    $assetMeta = $meta[$AssetType]
    if ( $assetMeta )
    {
        if ( $AttributeValue -eq $null )
        {
            return null;
        }

        $attrDef = $assetMeta.AssetType.AttributeDefinition | Where-Object name -eq $AttributeName;

        if ( $attrDef )
        {

            switch( $attrDef.attributetype )
            {
                "Date" { return [DateTime]::Parse($AttributeValue); }
                "Numeric" { return [Decimal]::Parse($AttributeValue); }
                "Text" { return $AttributeValue; }
                "Relation" { return $AttributeValue; }
                "AssetType" { return $AttributeValue; }
                "Opaque" { return $AttributeValue; }
                "Boolean" { return [Bool]::Parse($AttributeValue); }
                "LongText" { return $AttributeValue; }
                "State" { return $AttributeValue; }
                "LongInt" { return [Int64]::Parse($AttributeValue); }
                "Rank" { return $AttributeValue; }
                "Duration" { return $AttributeValue; }
                "Blob" { return $AttributeValue; }
                "Guid" { return [Guid]::Parse($AttributeValue); }
                "Password" { return $AttributeValue; }
                "LocalizerTag" { $AttributeValue; }            
                default { return $null }
            }
        }
        else
        {
            throw "AssetType '$AssetType' does not have attribute of '$AttributeName'"
        }
    }
    else
    {
        throw "AssetType of name '$AssetType' not found in meta"
    }
}

<#
.Synopsis
    Given an object from the API, convert it into a friendlier PS object
	
.Parameter AssetXml
	The XML returned from Invoke-RestMethod 

.Outputs
	An object hydrated from JSON

#>
function ConvertFrom-V1Xml
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]
[ValidateScript({ (Get-Member -InputObject $_ -Name Asset) -and (Get-Member -InputObject $_.Asset -Name Attribute) -and (Get-Member -InputObject $_.Asset -Name Relation) })]
$AssetXml
)
    Set-StrictMode -Version Latest

    $asset = $AssetXml.Asset
    $AssetType =  ($asset.Attribute | Where-Object name -eq 'AssetType' ).'#text'

    $ret = @{}
    foreach ( $a in $asset.Attribute | Where-Object name -NotLike "*.*" )
    {
        Write-Verbose "Converting $($AssetType).$($a.name)"
        if ( Get-Member -InputObject $a -Name "#text" )
        {
            $ret[$a.name] = getXmlValue $AssetType $a.name $a.'#text'
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
