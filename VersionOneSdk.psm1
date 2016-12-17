#requires -Version 5.0

# for now separate module so can reload other scripts w/o losing meta
Import-Module (Join-Path $PSScriptRoot Get-V1Meta.psm1)

# load all the script files into this module
foreach( $i in (Get-ChildItem (Join-Path $PSScriptRoot "Scripts\*.ps1") -File ))
{
    . $i
}

Export-ModuleMember -Function "*-V1*" -Alias "*"

if ( -not $script:baseUri)
{
    Write-Warning "V1 PowerShell API loaded.  Run Set-V1Connection to set Uri and credentials"
    Write-Warning "If tab-completion doesn't work.  Run Get-V1Meta | Out-Null and check output."
} 