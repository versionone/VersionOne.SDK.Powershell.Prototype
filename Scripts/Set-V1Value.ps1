function Set-V1Value
{
param( 
[Parameter(Mandatory,ValueFromPipeline)]
$asset, 
[Parameter(Mandatory)]
[string] $name, 
$value )

process
{
    Set-StrictMode -Version Latest

    if ( -not (Get-Member -Input $asset -name $name ))
    {
        Add-Member -InputObject $asset -MemberType NoteProperty -Name $name -Value $value
    }
    else
    {
        $asset.$name = $value
    }
    return $asset
}

}