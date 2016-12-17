# VersionOne PowerShell SDK Tutorial 6 -- Updating Assets

# Prereq -- Run 01 to install and load the SDK
# Prereq -- Run 04 to add assets

$stories = v1get Story -Find "PsSdkTestStory*" -FindIn Name -Attribute Name,Description
$stories | select name,description | ft

# change the descriptions and save them. Since the ID is set, it will update instead of create them
$stories | % { $_.Description = "New description for $($_.Name)" }
$stories | v1Save | Out-Null # ignore output in this case

# re-get them to check 
$stories = v1get Story -Find "PsSdkTestStory*" -FindIn Name
$stories | select name,description | ft

# Note! Many assets have an Order attribute that if you don't intend on changing, don't update.