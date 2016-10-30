$script:sortedKeys = $null


<#
.Synopsis
	Get AssetType Names

.Parameter Force
	force reload from the server

.Outputs
	sorted string array of assetTypes

#>
function Get-V1MetaAssetName
{
[CmdletBinding()]
param(
[switch] $force    
)

    if ( $force -or (-not $script:sortedKeys) )
    {
        $script:sortedKeys = (Get-V1Meta -force:$force).keys  | Sort-Object
    }    

    return $script:sortedKeys
}

New-Alias -Name v1metaname -Value Get-V1MetaAssetName