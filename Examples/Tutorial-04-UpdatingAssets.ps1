# VersionOne PowerShell SDK Tutorial -- Updating Assets

# Prereqs -- Install and Save tutorials

$stories = v1get Story -Find "PsSdkTestStory*" -FindIn Name -Attribute Name,Description
$stories | select id,name,description | ft

# change the descriptions and save them. Since the ID is set, it will update instead of create them
$stories | % { $_.Description = "New description for $($_.Name)" }
$stories | v1Save | Out-Null # ignore output in this case

# re-get them to check 
$stories = v1get Story -Find "PsSdkTestStory*" -FindIn Name
$stories | select id,name,description | ft

# Note! Many assets have an Order attribute that if you don't intend on changing, don't update.


# can delete by passing in IDs or object with ID.  It returns the Oid with the moment  
$stories[0].ID | Remove-V1Asset
$stories[1..($stories.Count-1)] | v1del 


v1get Story -Find "PsSdkTestStory*" -FindIn Name -Attribute Name,Description 

