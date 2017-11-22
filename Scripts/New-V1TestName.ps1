<#
.Synopsis
    Create n number of names with a number in them
#>
function New-V1TestName
{
[CmdletBinding(SupportsShouldProcess)]
param(
[Parameter(Mandatory)]
[ValidateRange(1,[Int]::MaxValue)]
$count, 
$prefix, 
$suffix)

    return (1..$count) | ForEach-Object { "$prefix$_$suffix" }
}