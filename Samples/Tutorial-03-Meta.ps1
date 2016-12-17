﻿# VersionOne PowerShell SDK Tutorial 3 -- Meta

# Prereq -- Run 01 to install and load the SDK

# Meta describes all the assets and their attributes
# Get-V1Meta* functions are used by the SDK to validate object
# and provide tab completion.  You can use them to explore
# meta from PowerShell.  You can also view all the meta from
# http://$(Get-V1BaseUri)/meta.v1?xsl=api.xsl

# Get all the meta data as nested hash tables.  This is used internally
Get-V1Meta

# Get all the asset type names
Get-V1MetaName

# Get all the attributes for a story
Get-V1MetaAssetType Story | Sort Name | Format-Table
