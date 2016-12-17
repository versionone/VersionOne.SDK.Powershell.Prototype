<#
.Synopsis
	Helper for save and remove relation since they are nearly identical

#>
function saveAssetOrRelation
{
[CmdletBinding(SupportsShouldProcess)]
param (
[Parameter(Mandatory,ValueFromPipeline)]
$Asset,
[string[]] $Attribute,
[switch] $RemovingRelation
)

process
{
    Set-StrictMode -Version Latest

    $action = "Saving Asset"
    if ( $RemovingRelation)
    {
        $action = "Removing Relation"
        if ( -not $Attribute )
        {
            throw "Must supply Attribute when $action"
        }
    }

    testAsset $Asset

    $AssetType = Get-V1AssetTypeName $Asset.AssetType

    $uri = "http://$(Get-V1BaseUri)/rest-1.v1/Data/$AssetType"
    if ( ($Asset | Get-Member -Name "id") -and $Asset.id)
    {
        # updating or removing
        $id = $Asset.id -split ":"
        if ( $id.Count -gt 1 )
        {
            $uri += "/$($id[1])"
        }
        else
        {
            $uri += "/$($id[0])"
        }
    }
    elseif ($RemovingRelation)
    {
        throw "Must supply object with id attribute for $action"
    }

    $body = ConvertTo-V1Json $Asset -stripDotted -removeRelations:$RemovingRelation -Attribute $Attribute
    if ( $PSCmdlet.ShouldProcess("$uri", "$action of from type $AssetType"))
    {
        try
        {
            $result = InvokeApi -Uri $uri `
                    -Body $body `
                    -Method POST
        }
        catch
        {
            throw "Exception $action for asset of type $AssetType with body of:`n$('='*80)`n$body`n$('='*80)`n$_"
        }
        $result | ConvertFrom-V1Json
    }
    else
    {
        Write-Verbose($body)
    }

}

}


Set-Alias -Name v1delrel Remove-V1Relation
