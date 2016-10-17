function ConvertTo-V1AssetValue
{
param(    
[Parameter(Mandatory)]
$value, 
[Parameter(Mandatory)]
$attributeMeta )

    Set-StrictMode -Version Latest

    if ( $value -ne $null )
    {
        #TODO smarter conversion?
        switch ($attributeMeta.AttributeType)
        {
            "Date" { return [Convert]::ToDateTime($value); }
            "Numeric" { return [Convert]::ToDecimal($value); }
            "Text" { return $value.ToString(); }
            "Relation" { return $value; }
            "AssetType" { return $value; }
            "Opaque" { return $value; }
            "Boolean" { return [Convert]::ToBool($value); }
            "LongText" { return $value.ToString(); }
            "State" { return $value; }
            "LongInt" { return [Convert]::ToInt64($value); }
            "Rank" { return $value; }
            "Duration" { return $value; }
            "Blob" { return $value; }
            "Guid" { return [Guid]::Parse($value.ToString()); }
            "Password" { return $value; }
            "LocalizerTag" { $value; }            
            default {
                throw "Unknown AttributeType of $($attributeMeta.AttributeType) on $($attributeMeta.Name)" 
                }
        }
    }        
    return $value
}