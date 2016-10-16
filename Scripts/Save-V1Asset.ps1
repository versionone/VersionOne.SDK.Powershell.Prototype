function Save-V1Asset
{
[CmdletBinding(SupportsShouldProcess)]
param(
[Parameter(Mandatory,ValueFromPipeline)]  
$asset,
[Parameter(Mandatory)]
[string] $token,
[Parameter(Mandatory)]
[string] $baseUri  
)
    Set-StrictMode -Version Latest

    if ( -not (Get-Member -InputObject $asset -Name "AssetType"))
    {
        throw "Must supply object with AssetType property"
    }

    $uri = "http://$baseUri/rest-1.v1/Data/$($asset.AssetType)"
    if ( ($asset | Get-Member -Name "id") -and $asset.id)
    {
        # updating
        $id = $asset.id -split ":"
        if ( $id.Count -gt 1 )
        {
            $uri += "/$($id[1])"
        }
        else
        {
            $uri += "/$($id[0])"
        }
    }

    if ( $PSCmdlet.ShouldProcess("$uri", "Save-V1Asset of type $($asset.AssetType)"))
    {
        $body = (ConvertTo-V1Xml $asset -baseUri $baseUri)
        try 
        {
            $result = (Invoke-RestMethod -Uri $uri `
                    -Body $body `
                    -ContentType "application/xml"  `
                    -Method POST `
                    -headers @{Authorization="Bearer $token";Accept="application/json";})
        }
        catch
        { 
            throw "Exception Saving asset of type $($asset.AssetType) with body of:`n$('='*80)`n$body`n$('='*80)`n$_" 
        }
        $result | ConvertFrom-V1Json
    }
    else
    {
        Write-Verbose(ConvertTo-V1Xml $asset -baseUri $baseUri)
    }

}