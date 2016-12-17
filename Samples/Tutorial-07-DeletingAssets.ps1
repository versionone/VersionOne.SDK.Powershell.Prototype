# VersionOne PowerShell SDK Tutorial 7 -- Deleting Assets

# Prereq -- Run 01 to install and load the SDK
# Prereq -- Run 04 to add assets

$stories = v1get Story -Find "PsSdkTestStory*" -FindIn Name -Attribute Name,Description
$stories | select name,description | ft

# can delete by passing in IDs or object with ID.  It returns the Oid with the moment  
$stories[0].ID | Remove-V1Asset
$stories[1..($stories.Count-1)] | v1del 


v1get Story -Find "PsSdkTestStory*" -FindIn Name -Attribute Name,Description 

