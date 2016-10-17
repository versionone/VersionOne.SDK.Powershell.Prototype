# for now separate module so can reload other scripts w/o losing meta
Import-Module (Join-Path $PSScriptRoot Get-V1Meta.psm1)


# load all the script files into this module
foreach( $i in (Get-ChildItem (Join-Path $PSScriptRoot "scripts\*.ps1") -File ))
{
    . $i
}

Export-ModuleMember -Function "*-*","TabExpansion"

if ( -not $script:baseUri)
{
    Write-Warning "V1 PowerShell API loaded.  Run Set-V1Default to set Uri and credentials"
} 