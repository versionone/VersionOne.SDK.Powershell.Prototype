foreach( $i in (Get-ChildItem (Join-Path $PSScriptRoot "scripts\*.ps1") -File ))
{
    . $i
}

Export-ModuleMember -Function *