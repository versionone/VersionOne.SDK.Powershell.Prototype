function getOid
{
param(
[Parameter(Mandatory)]
$o
)
    if ( $o -is 'string' )
    {
        if ( $o  -match ".+\:\d+" )
        {
            return $o
        }
        else 
        {
            throw "String '$o' must be an OID (assetType:idNum)"
        }
    }
    elseif ( Get-Member -input $o -name "ID" )
    {
        return $o.ID
    }
    else
    {
        throw "Object must have an ID property for removal of relationship."
    }
}
