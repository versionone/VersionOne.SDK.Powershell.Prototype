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

    $uri = "http://$baseUri/rest-1.v1/Data/$assetType" -join $ID, "/"
    if ( $properties )
    {
        $uri += "?sel=$($properties -join ",")"
    }

    (Invoke-RestMethod -Uri $uri -ContentType "application/json"  `
            -Method GET `
            -headers @{Authorization="Bearer $token";Accept="application/json";}).Assets | 
        ConvertFrom-V1Json

}