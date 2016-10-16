<#
.Synopsis
	Get version assets from the sever
	
.Parameter assetType
	Asset type.  To see valid values (Get-V1Meta).keys | sort

.Parameter ID
	optional ID to specify to get just one item

.Parameter filter
	optional filter for limiting results

.Parameter token
	security token

.Parameter baseUri
	baseUri for the REST server

.Outputs
	Asset objects of the given type

.Example
    Set-V1Default -baseUri "localhost/VersionOne.Web" -token "1.bxDPFh/9y3x9MAOt469q2SnGDqo="
    $scopes = Get-V1Asset -assetType "Scope" -properties "Name"

    Get all scopes, just the Name field
#>
function Get-V1Asset
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]
[string] $assetType,
[int] $ID,
[string[]] $properties,
[Parameter(Mandatory)]
[string] $token,
[string] $baseUri = "localhost/VersionOne.Web"
)
    Set-StrictMode -Version Latest

    Write-Verbose( "BaseUri: $baseUri AssetType: $assetType Properties: $properties ID: $ID" )

    $uri = "http://$baseUri/rest-1.v1/Data/$assetType"
    if ( $ID )
    {
        $uri += "/$ID"
    }
    if ( $properties )
    {
        $uri += "?sel=$($properties -join ",")"
    }

    $result = (Invoke-RestMethod -Uri $uri -ContentType "application/json"  `
            -Method GET `
            -headers @{Authorization="Bearer $token";Accept="application/json";})
    if ( $result | Get-Member -Name "Assets" )
    {
        $result.Assets | ConvertFrom-V1Json
    }
    else
    {
        $result | ConvertFrom-V1Json
    }

}
