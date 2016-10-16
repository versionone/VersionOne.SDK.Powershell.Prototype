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