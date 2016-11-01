<#
.Synopsis
	Save (add or update) a V1 Asset
	
.Description
	If the asset has an id, it will update it, otherwise it will create it

.Parameter asset
	The asset object returned from Get-V1Asset or New-V1Asset

.Outputs
	The created or updated asset, as returned from the REST API

.Example
    $savedStory = New-V1Asset Story -attributes @{Name="Test";Scope="Scope:0"} | Save-V1Asset 

    New up a story and save it to the server

.Example
    $bundles = v1asset Bundle -attributes ChangeSets -id 1016
    $changeSets = v1asset ChangeSet -attributes Name -id 2144
    $bundles[0].ChangeSets = $changeSets[0].id
    Save-V1Asset $bundles[0]

    Add a ChangeSet to a Bundle 

#>
function Save-V1Asset
{
[CmdletBinding(SupportsShouldProcess)]
param(
[Parameter(Mandatory,ValueFromPipeline)]  
$asset  
)

process
{
    Set-StrictMode -Version Latest

    if ( -not (Get-Member -InputObject $asset -Name "AssetType"))
    {
        throw "Must supply object with AssetType attribute"
    }

    $uri = "http://$(Get-V1BaseUri)/rest-1.v1/Data/$($asset.AssetType)"
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

    $body = ConvertTo-V1Json $asset -stripDotted
    if ( $PSCmdlet.ShouldProcess("$uri", "Save-V1Asset of type $($asset.AssetType)"))
    {
        try 
        {
            $result = InvokeApi -Uri $uri `
                    -Body $body `
                    -Method POST
        }
        catch
        { 
            throw "Exception Saving asset of type $($asset.AssetType) with body of:`n$('='*80)`n$body`n$('='*80)`n$_" 
        }
        $result | ConvertFrom-V1Json
    }
    else
    {
        Write-Verbose($body)
    }

}

}

Set-Alias -Name v1save Save-V1Asset