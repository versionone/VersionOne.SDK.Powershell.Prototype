$script:meta = $null

function returnMeta( $AssetType )
{
    if ( $AssetType )
    {
        return $script:meta[$AssetType]
    }
    else
    {
        return $script:meta
    }
}

<#
.Synopsis
	Get VersionOne meta data about assets

.Parameter AssetType
    An asset type to get a hash table of attributes.  Same as (Get-V1Meta)[$AssetType]    

.Parameter Force
	Force reload from the server

.Parameter Noload
    Don't load if not already cached, will retun $null

.Link
    https://community.versionone.com/VersionOne_Connect/Developer_Library/Getting_Started/Platform_Concepts/Endpoints/rest-1.v1%2F%2FData

    REST API documentation

.Outputs
	HashTable of Asset names to data about them

#>
function Get-V1Meta
{
[CmdletBinding()]
param(
[string] $AssetType,
[switch] $Force,
[switch] $NoLoad
)


try 
{
    
    Set-StrictMode -Version Latest

    if ( $env:APPDATA )
    {
        $tempFile = Join-Path ($env:APPDATA) "V1Api\meta\$((Get-V1BaseUri) -replace '[\\/:]','_').xml"
    }
    else
    {
        $tempFile = Join-Path $env:HOME "V1Api/meta/$((Get-V1BaseUri) -replace '[\\/:]','_').xml"
    }

    if ( -not $Force )
    {
        if ( $script:meta  )
        {
            Write-Verbose "Meta already loaded"
            return returnMeta $AssetType
        }

        if ( Test-Path $tempFile -PathType Leaf )
        {
            try 
            {
                $script:meta = Import-Clixml $tempFile
                Write-Verbose "Read meta from cache file $tempFile"
                return returnMeta $AssetType
            }
            catch 
            {
                Write-Warning "Error trying to read cache file $tempFile, continuing"
            }
        }
    }
    if ( $NoLoad )
    {
        return $null
    }

    $activityName = "Processing meta (once per PowerShell session)"

    Write-Progress -Activity $activityName -PercentComplete 0 -CurrentOperation "Getting meta from server..." 

    Write-Verbose "Loading meta from http://$(Get-V1BaseUri)/meta.v1"
    $metaJson = Invoke-RestMethod -Uri "http://$(Get-V1BaseUri)/meta.v1" -Headers @{Accept="application/json"}

    $script:meta = @{}
    $i = 0
    $properties = $metaJson.AssetTypes | Get-Member -MemberType Properties
    if ( $properties )
    {
        $total = $properties.Count

        $properties | ForEach-Object {

            $name = $_.name

            Write-Progress -Activity $activityName -PercentComplete (100*($i++)/$total) -CurrentOperation $name

            $metum = @{}

            foreach ( $a in $metaJson.AssetTypes.$name.Attributes | Get-Member -MemberType Properties )
            {
                $attrName = $a.name
                $simpleName = $attrName
                if ( $simpleName.StartsWith("$name.") )
                {
                    $simpleName = ($simpleName -split '\.')[1]
                }
                $metum[$simpleName] = $metaJson.AssetTypes.$name.Attributes.$attrName | Select-Object Name,IsReadOnly,IsRequired,IsMultivalue,IsCustom,AttributeType,
                                @{n="RelatedNameRef";e={if ( $_.AttributeType -eq "Relation"){$_.RelatedAsset.nameref}else{$null}}}
            }
            $meta[$name] = $metum
        }

        Write-Progress -Activity $activityName -Completed 

    }
    $script:sortedKeys = $script:meta.Keys | Sort-Object

    try 
    {
        $folder = Split-Path $tempFile -Parent
        if ( -not (Test-Path $folder))
        {
            New-Item -Path $folder -ItemType Directory
        }
        Export-Clixml -Path $tempFile -InputObject $script:meta
        Write-Verbose "Wrote meta to cache file $tempFile"
    }
    catch 
    {
        Write-Warning "Failed to save cache file $tempFile`n$_"
    }

    return returnMeta $AssetType
}
catch 
{
    Write-Error "Error:`n$_`n$($_.ScriptStackTrace)"
}

}

New-Alias -Name v1meta -Value Get-V1Meta

Export-ModuleMember -Function "*-*"
