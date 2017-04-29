# VersionOne PowerShell SDK Tutorial -- Getting Assets

# Prereqs -- Install tutorial

# IMPORTANT Names are passed to the server as-is and the server is case-sensitive.  
# Use tab-completion whenever possible

# Get all the assets of a given type.  Tab completion for asset type works
Get-V1Asset EpicCategory | Format-Table

# Get an asset by id, with or without type
Get-V1Asset Scope -id Scope:0
Get-V1Asset Scope -id 0

# You can limit the attributes attributes returnd.  (Tab completion works for them)
Get-V1Asset EpicCategory -Attribute ColorName,Order,Name | Format-Table

# Filters restrict what you get back.  
# Pass in a string with the filter 
Show-V1Help -HelpType Filter # for details on the syntax
v1get EpicCategory -filter "ColorName!='iron'" -Attribute Name,ColorName | ft

# Use an filter object to write the filter with a PS expression, and use tab-completion in the braces, e.g. $f.<tab>
$f = v1filter EpicCategory
v1get EpicCategory -filter { $f.ColorName -ne 'iron' -and $f.Order -gt 20 }  `
                        -Attribute Name,ColorName | ft

# If you want to see the generated filter, use -Verbose 
v1get EpicCategory -filter { $f.ColorName -ne 'iron' -and $f.Order -gt 20 } -Verbose  -Attribute Name,ColorName | Out-Null

# You can use PS Sort-Object, or sort results on the server.  
# Tab completion works sort attributes 
v1get EpicCategory -Attribute Name -Sort Name

# You can also get assets as of a date
v1get EpicCategory -AsOf '2016-11-1' -Attribute Name,AssetState -Verbose | ft

# searches for a value in an attribute.  Verbose shows the syntax
Show-V1Help -HelpType Find
v1get EpicCategory  -Attribute Name -Find s* -FindIn Name -Verbose

# By default only 50 items are returned.  If you want more pass in MaxToReturn
(v1get Label -Attribute Name).Count
(v1get Label -Attribute Name -MaxToReturn -1).Count


# If your application wants paging you can use Get-V1AssetPaged
# that returns an object with the Total and Assets
# Get the first page of 9
$paged = Get-V1AssetPaged Label -Attribute Name,Description -Sort Name -PageSize 9
"Total count: $($paged.Total)"
$paged.Assets | ft

# get first 3 pages of 5 items each
$pageSize = 5
(0..2) | % {$page = $_; (v1paged Label -Attribute Name,Description -PageSize $pageSize `
                                -Sort Name -Start ($_*$pageSize)).Assets | select @{n="Page";e={$page}},Name,Description | ft }


