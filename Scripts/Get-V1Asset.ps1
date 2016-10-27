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
	optional filter for limiting results

.Outputs
	Asset objects of the given type

.Notes 
    https://community.versionone.com/VersionOne_Connect/Developer_Library/Learn_the_API/Data_API/Queries/select

    REST API select help    

    https://community.versionone.com/VersionOne_Connect/Developer_Library/Learn_the_API/Data_API/Queries/filter

    REST API filter help

.Example
    Set-V1Default -baseUri "localhost/VersionOne.Web" -token "1.bxDPFh/9y3x9MAOt469q2SnGDqo="
    $scopes = Get-V1Asset -assetType "Scope" -attributes "Name"

    Get all scopes, just the Name field

.Example
    Get-V1Asset -assetType ChangeSet -id 4434

    Get a changeset with id of 4434    
#>
function Get-V1Asset
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]
[string] $assetType,
$ID,
[string[]] $attributes,
[string] $filter
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
        $uri += "?sel=$($attributes -join ",")"
    }

    if ( $filter )
    {
        if ( $uri.Contains("?"))
        {
            $uri += "&"
        }
        else
        {
            $uri += "?"
        }
        $uri += "where=$filter"
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
