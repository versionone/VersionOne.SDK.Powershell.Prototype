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
	Get version assets from the sever
	
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
	Asset objects of the given type

.Example
    Set-V1Default -baseUri "localhost/VersionOne.Web" -token "1.bxDPFh/9y3x9MAOt469q2SnGDqo="
    $scopes = Get-V1Asset -assetType "Scope" -attributes "Name"

    Get all scopes, just the Name field

.Example
    Get-V1Asset -assetType ChangeSet -id 4434

    Get a changeset with id of 4434

.Example
    Get-V1Asset EpicCategory -asOf 2001-1-1

    Get a epic categories as they looked as of January 1, 2001

.Example 
    Get-V1Asset Story -attributes Name,Status -pageSize 10 -startPage 0 | ft

    Get name and status of first 10 Stories

.Example
    Get-V1Asset PrimaryWorkitem -attributes Name,Status,ToDo,Estimate  -filter "Estimate>'1'" | ft

    Get PrimaryWorkitems that have an estimate > 1.  Note that when not using a variable, you must enclose the filter in double quotes, otherwise it will return an error.            
#>
function Get-V1Asset
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]
[string] $assetType,
$ID,
[string[]] $attributes,
[string] $filter,
[string] $sort,
[ValidateRange(-1,[int]::MaxValue)]
[int] $startPage = -1,
[ValidateRange(1,[int]::MaxValue)]
[int] $pageSize = 1,
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

    if ( $startPage -ge 0 )
    {
        $uri = appendToUri $uri "page=${pageSize},$startPage"
    }

    if ( $asOf )
    {
        $uri = appendToUri $uri "asof=$($asOf.ToString("s"))"
    }

    $result =  InvokeApi -Uri $uri

    if ( $result )
    {
        if ( $result | Get-Member -Name "Assets" )
        {
            $result.Assets | ConvertFrom-V1Json
        }
        else
        {
            $result | ConvertFrom-V1Json
        }
    }
    else 
    {
        return $null    
    }
}
