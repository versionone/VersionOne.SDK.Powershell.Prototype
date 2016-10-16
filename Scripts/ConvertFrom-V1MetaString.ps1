function ConvertFrom-V1MetaString
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]
[string] $assetTypeName,
[Parameter(Mandatory)]
[string] $attributeName,
[string] $attributeValue
)
    $meta = Get-V1Meta

    $assetType = $meta[$assetTypeName]
    if ( $assetType )
    {
        if ( $attributeValue -eq $null )
        {
            return null;
        }

        $attrDef = $assetType.AssetType.AttributeDefinition | Where-Object name -eq $attributeName;

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
            throw "AssetType '$assetTypeName' does not have attribute of '$attributeName'"
        }
    }
    else
    {
        throw "AssetType of name '$assetTypeName' not found in meta"
    }
}