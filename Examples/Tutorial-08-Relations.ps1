# VersionOne PowerShell SDK Tutorial 8 -- Relationships

# Prereq -- Run 01 to install and load the SDK

# Assets can have single or mult relationships with other assets this shows 
# the relations first single then multi
v1asset story | ? { $_.AttributeType -eq "Relation" -and $_.IsMultivalue -eq $false } | sort Name | ft -Property Name, RelatedNameRef, IsMultivalue
v1asset story | ? { $_.AttributeType -eq "Relation" -and $_.IsMultivalue -eq $true } | sort Name | ft -Property Name, RelatedNameRef, IsMultivalue

# Relationship values are IDs (OIDs)
# Recall from creating stories, Scope is required, and single relationship.
$story = v1new Story -Required; $story
$scope = v1get Scope -ID 0;$scope
$status = v1get Status -MaxToReturn 1;$status

$story.Scope = $scope
$story.Name = "PsSdkStory10"

#status is single relation
v1set $story -Name Status -Value $status

# owners is a multi relation
$owners = v1get Member -Attribute Name;$owners

v1set $story Owners $owners[0]

# save the story, using Verbose to show what is sent to the server
$story = v1save $story -Verbose

# now we want to add more owners to the existing relation, just get the owners
$story = v1get Story -ID $story.ID -Attribute Owners,Name,Status;$story

# notice that relationships names show up as dotted attributes that require quotes to access
$story.'Owners.Name'

# Since PS likes to simplify arrays of 1 to simple items, make sure you end up 
# with an array of string that are IDs
$story.Owners = $owners[2..3].ID+$story.Owners
$story.Owners 

# save and verify the members were added
$story = v1save $story
$story = v1get Story -ID $story.ID -Attribute Owners,Name,Status;$story

# now remove one of them and verify
Remove-V1Relation $story -Attribute Owners -ID Member:2190 -Verbose
$story = v1get Story -ID $story.ID -Attribute Owners,Name,Status;$story

# since owners in optional, clear is out completely by passing in the current list
v1delrel $story -Attribute Owners -ID $story.Owners -Verbose

# clear optional status
v1delrel $story -Attribute Status -ID $story.Status

$story = v1get Story -ID $story.ID -Attribute Owners,Name,Status;$story

# in addition to adding relation via save, you can add with a function
Add-V1Relation $story -Attribute Owners -ID $owners[0]
v1addrel $story -Attribute Owners -ID $owners[1]
$story = v1get Story -ID $story.ID -Attribute Owners,Name,Status;$story

# clean up
v1del $story 