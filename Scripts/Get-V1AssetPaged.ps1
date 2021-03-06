function appendToUri
{
param(
[Parameter(Mandatory)]
$uri,
[Parameter(Mandatory)]
$s
)
    if ( $uri.Contains("?"))
    {
        return "${uri}&$s"
    }
    else
    {
        return "${uri}?$s"
    }
}

<#
.Synopsis
	Get V1 assets from the server, in a paged manner.  See Get-V1Asset for non-paged and more examples

.Parameter AssetType
	Asset type.  To see valid values (Get-V1Meta).keys | sort

.Parameter ID
	Optional ID to specify to get just one item, can be <type>:num, or just the number

.Parameter Attribute
	Optional list of attributes to return, otherwise it returns default set

.Parameter Filter
	Optional filter (where clause) for limiting results. May be a string or script block.

.Parameter Sort
	Optional sort attributes. For details run Get-V1Help Sort

.Parameter Start
	Optional starting item (NOT page number), defaults to first item of 0

.Parameter PageSize
	Optional pageSize, if Start is used defaults to 50

.Parameter AsOf
	Optional asOf DateTime to get an asset as of that time

.Parameter Find
	Prefix string to find in common attributes, or ones specified in FindIn.  Anything after * is ignored.  If * is not supplied, it is appended.

.Parameter FindIn
	Attribute for Find.  Uses default attributes for type if not supplied

.Parameter Raw
	Return the raw JSON instead of converting it to objects

.Outputs
	Object with Total and Assets (array of asset objects of the given type)

.Example
    $ret = Get-V1AssetPaged Story -Attribute Name,Status -pageSize 10 -Start 0
    "Total is $($ret.total)"
    $ret.Assets | ft

    Get name and status of first 10 Stories

#>
function Get-V1AssetPaged
{
[CmdletBinding()]
[OutputType([HashTable])]
param(
[Parameter(Mandatory)]
[string] $AssetType,
[Parameter(ValueFromPipeline)]
$ID,
[string[]] $Attribute,
$Filter,
[string] $Sort,
[ValidateRange(0,[int]::MaxValue)]
[int] $Start = 0,
[ValidateRange(-1,[int]::MaxValue)]
[int] $PageSize = 50,
[DateTime] $AsOf,
[string] $Find,
[string[]] $FindIn,
[switch] $Raw
)

process
{

    Set-StrictMode -Version Latest

    if ( $PageSize -le 0 )
    {
        $PageSize = [int]::MaxValue
    }

    Write-Verbose( "BaseUri: $(Get-V1BaseUri) AssetType: $AssetType Attribute: $Attribute ID: $ID" )

    $AssetType = Get-V1AssetTypeName $AssetType

    $uri = "$(Get-V1BaseUri)/rest-1.v1/Data/$AssetType"
    if ( $null -ne $ID )
    {
        if ( $ID -is "string" -and $ID.Contains(":") )
        {
            $parts = ($ID -split ":")
            if ( $parts[0] -ne $AssetType )
            {
                throw "AssetType of $AssetType does not match type in ID of $($parts[0])"
            }
            $ID = $parts[1]
        }
        $uri += "/$ID"
    }

    if ( $Attribute )
    {
        $uri = appendToUri $uri "sel=$($Attribute -join ",")"
    }

    if ( $Filter )
    {
        if ( $Filter -is 'string')
        {
            $uri = appendToUri $uri "where=$Filter"
        }
        elseif ( $Filter -is 'scriptblock')
        {
            $uri = appendToUri $uri "where=$(ConvertFrom-V1Filter $Filter)"
        }
    }

    if ( $Sort )
    {
        $uri = appendToUri $uri "sort=$Sort"
    }

    if ( $PageSize -ne [int]::MaxValue )
    {
        $uri = appendToUri $uri "page=${pageSize},$Start"
    }

    if ( $AsOf )
    {
        $uri = appendToUri $uri "asof=$($AsOf.ToString("s"))"
    }

    if ( $Find )
    {
        if ( $Find -notmatch "\*" )
        {
            $Find += "*"
        }
        $uri = appendToUri $uri "find=$Find"
        if ( $FindIn )
        {
            $uri = appendToUri $uri "findin=$($FindIn -join ",")"
        }
    }

    $result =  InvokeApi -Uri $uri

    if ( $Raw )
    {
        return $result
    }

    $ret = @{Total=0;Assets = $null}

    if ( $result )
    {
        if ( $result | Get-Member -Name "total" )
        {
            $ret.Total = $result.total
        }

        if ( $result | Get-Member -Name "Assets" )
        {
            $ret.Assets = $result.Assets | ConvertFrom-V1Json
        }
        else
        {
            $ret.Assets = $result | ConvertFrom-V1Json
        }
        if ( -not $ret.Assets -is "array")
        {
            $ret.Assets = ,$ret.Assets
        }
    }
    $ret
}

}

New-Alias -Name v1paged -Value Get-V1AssetPaged