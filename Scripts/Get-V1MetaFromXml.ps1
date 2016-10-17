$script:meta = $null

function Get-V1MetaFromXml
{
[CmdletBinding()]
param(
)
    Set-StrictMode -Version Latest

    if ( $script:meta )
    {
        Write-Information "Found existing meta"
        return $script:meta;
    }

    $metaXml = [xml](Invoke-WebRequest -Uri "http://$(Get-V1BaseUri)/meta.v1")
    $metaJson = Invoke-RestMethod -Uri "http://$(Get-V1BaseUri)/meta.v1" -Headers @{Accept="application/json"}

    function getBase( $o )
    { 
        if ( Get-Member -input $o -Name Base ) { $o.Base.nameref} else {$null} 
    }

    function isBase ( $o )
    {
        if ( [bool](getBase $o) )
        {
            return 1
        }
        else
        {
            return 0
        }
    }

    $script:meta = @{}
    $metaXml.Meta.AssetType | ForEach-Object { $script:meta[$_.GetAttribute("name")] = [PSCustomObject]@{ AssetType = $_; Base = getBase $_; Depth = isBase $_ } }

    function getDepth( $item, [int]$count )
    {
        if ( $item.Base )
        {
            $parent = $script:meta[$item.Base]
            if ( $parent )
            {
                return getDepth $parent ($count+1)
            }
        }
        return $count
    }

    foreach ( $m in $script:meta.Values | ? Depth -gt 0 )
    {
        $m.Depth = getDepth $m 1
    }

    return $script:meta

}