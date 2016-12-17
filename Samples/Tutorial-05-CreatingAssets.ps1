# VersionOne PowerShell SDK Tutorial 5 -- Creating Assets

# Prereq -- Run 01 to install and load the SDK

# To add a new asset, first create the asset with New-V1Asset
# then update any values on it
# then save it with Save-V1Asset

# create an empty asset with only require attributes on it
$story = New-V1Asset Story -Required;$story

# to save, all required values must be set
$story.Name = "PsSdkTestStory1"
$story.Scope = (v1get Scope -ID 0).ID
$story

# save the story.  Now it has an id
$savedStory = Save-V1Asset $story;$savedStory 

# view writable text attributes for story
Get-V1MetaAssetType Story  | ? AttributeType -like '*text*' | sort Name | ft

# create a story with values
$story = v1new Story -Attribute @{Name="PsSdkTestStory2";Scope=$story.Scope;Description="Something clever"};$story
$savedStory = Save-V1Asset $story;$savedStory 

# if you try to create an asset without -Required or filling in all required
# it will tell you what's missing
$story = v1new Story -Attribute @{Name="PsSdkTestStory2"}

# You ask, "No tab-completion for setting attributes?" Use Set-V1Value
# use tab to cycle through all writable attributes on an asset

# only set Name in the Attribute, but use -Required to create all required attributes
$story = v1new Story -Attribute @{Name="PsSdkTestStory3"} -Required;$story
Set-V1Value $story -Name Scope -Value (v1get Scope -ID 0).ID
Set-V1Value $story -Name Description -Value "Test description"
$story

# or set all writeable attributes with -Full (it will send all of them to the server)
$story = v1new Story -Attribute @{Name="PsSdkTestStory4"} -Full;$story

# for bulk adding of test data, you can create a template, then use pipeline and -Name parameter
$defaultEpicProps = @{Description="Added via PS";Scope="Scope:0"}

# add 20 epics using little helper to create 20 names
$epics = New-V1TestName 20 -prefix "MyTestEpic" | New-V1Asset -assetType Epic -Name Name `
            -DefaultAttribute $defaultEpicProps 
$epics

# add all the epics via pipeline
$epics | Save-V1Asset -WhatIf