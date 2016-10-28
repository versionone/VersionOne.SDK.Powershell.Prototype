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
	Get V1 assets from the server, in a paged manner.  See Get-V1Asset for non-paged
	
.Parameter assetType
	Asset type.  To see valid values (Get-V1Meta).keys | sort

.Parameter ID
	optional ID to specify to get just one item, can be <type>:num, or just the number

.Parameter attributes
	optional list of attributes to return, otherwise it returns default set

.Parameter filter
	optional filter (where clause) for limiting results.  For details run Get-V1Help Filter 

.Parameter sort
	optional sort attributes. For details run Get-V1Help Sort  

.Parameter startPage
	optional starting page, first page is 0

.Parameter pageSize
	optional pageSize, if startPage is used defaults to 1

.Parameter asOf
	optional asOf DateTime to get an asset as of that time

.Outputs
	Object with Total and Assets (array of asset objects of the given type)

.Example 
    $ret = Get-V1AssetPaged Story -attributes Name,Status -pageSize 10 -startPage 0
    "Total is $($ret.total)" 
    $ret.Assets | ft

    Get name and status of first 10 Stories

#>
function Get-V1AssetPaged
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]
[string] $assetType,
$ID,
[string[]] $attributes,
[string] $filter,
[string] $sort,
[ValidateRange(0,[int]::MaxValue)]
[Parameter(Mandatory)]
[int] $startPage = 0,
[ValidateRange(1,[int]::MaxValue)]
[int] $pageSize = [int]::MaxValue,
[DateTime] $asOf
)
    Set-StrictMode -Version Latest

    Write-Verbose( "BaseUri: $(Get-V1BaseUri) AssetType: $assetType Attributes: $attributes ID: $ID" )

    if ( -not (Get-V1Meta)[$assetType] )
    {
        throw "$assetType was not found in meta"
    }
    
    $uri = "http://$(Get-V1BaseUri)/rest-1.v1/Data/$assetType"
    if ( $ID )
    {
        if ( $ID -is "string" -and $ID.Contains(":") )
        {
            $parts = ($ID -split ":")
            if ( $parts[0] -ne $assetType )
            {
                throw "AssetType of $assetType does not match type in ID of $($parts[0])"
            }
            $ID = $parts[1]
        }
        $uri += "/$ID"
    }

    if ( $attributes )
    {
        $uri = appendToUri $uri "sel=$($attributes -join ",")" 
    }

    if ( $filter )
    {
        $uri = appendToUri $uri "where=$filter"
    }   

    if ( $sort )
    {
        $uri = appendToUri $uri "sort=$sort"
    }   

    if ( $pageSize -ne [int]::MaxValue )
    {
        $uri = appendToUri $uri "page=${pageSize},$startPage"
    }

    if ( $asOf )
    {
        $uri = appendToUri $uri "asof=$($asOf.ToString("s"))"
    }

    $result =  InvokeApi -Uri $uri

    $ret = @{Total=0;Assets = $null}

    if ( $result )
    {
        if ( $result | Get-Member -Name "total" )
        {
            $ret.Total = $result.total
        }

        if ( $result | Get-Member -Name "Assets" )
        {
            $ret.Assets = ,($result.Assets | ConvertFrom-V1Json)
        }
        else
        {
            $ret.Assets = ,($result | ConvertFrom-V1Json)
        }
    }
    $ret
}
