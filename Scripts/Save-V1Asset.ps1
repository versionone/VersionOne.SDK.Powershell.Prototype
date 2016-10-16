function Save-V1Asset
{
[CmdletBinding(SupportsShouldProcess)]
param(
[Parameter(Mandatory,ValueFromPipeline)]  
$asset,
[Parameter(Mandatory)]
[string] $token,
[string] $baseUri = "localhost/VersionOne.Web"  
)
    Set-StrictMode -Version Latest

    if ( -not (Get-Member -InputObject $asset -Name "AssetType"))
    {
        throw "Must supply object with AssetType property"
    }

    $uri = "http://$baseUri/rest-1.v1/Data/$($asset.AssetType)"
    if ( $PSCmdlet.ShouldProcess("$uri", "Save-V1Asset of type $($asset.AssetType)"))
    {
        (Invoke-RestMethod -Uri $uri `
                    -Body (ConvertTo-V1Json $asset) `
                    -ContentType "application/json"  `
                    -Method POST `
                    -headers @{Authorization="Bearer $token";Accept="application/json";})  |
                    ConvertFrom-V1Json 
    }
    else
    {
        Write-Verbose(ConvertTo-V1Json $asset)
    }

}