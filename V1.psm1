Import-Module (Join-Path $PSScriptRoot Get-V1Meta.psm1)

foreach( $i in (Get-ChildItem (Join-Path $PSScriptRoot "scripts\*.ps1") -File ))
{
    . $i
}

Export-ModuleMember -Function *