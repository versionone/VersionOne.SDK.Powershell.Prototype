<#
.Synopsis
    Add a V1 Admin user, for testing

.Parameter MemberName
    Name of member to add as an administrator

.Example 
    "jblow","jdoe","mmouse" | New-V1AdminUser

    Add the list of users as admins. 

.Example 
    (Get-Content .\adminusernames.txt) | New-V1AdminUser

    Add the users listed in the file 

.Example 
    Get-AdGroupMember  "Developers" | Select-Object -expand SamaccountName | New-V1AdminUser

    Add all the users in the "Developers" AD group as admins.  Note to install the AD tools on Windows workstation, you have to install RSAT.  https://blogs.technet.microsoft.com/ashleymcglone/2016/02/26/install-the-active-directory-powershell-module-on-windows-10/ is one method.
#>
function New-V1AdminUser
{
[Cmdletbinding(SupportsShouldProcess)]
param(
[Parameter(ValueFromPipeline,Mandatory)]
$MemberName
)

begin
{
    $ROOT_SCOPE = 'Scope:0'
    $ADMIN_ROLE = 'Role:1'
    $prevPref = $InformationPreference
    $InformationPreference = "Continue"
}

process
{
    write-verbose "Adding one"
    Set-StrictMode -Version Latest

    if ( $PSCmdlet.ShouldProcess("","") )
    {
        # since New- lint barks unless have ShouldProcess
    }

    $member = @{
                Name= $MemberName
                Username= $MemberName
                Password= $MemberName
                DefaultRole = $ADMIN_ROLE
                IsCollaborator = $false
                Nickname = $MemberName
                NotifyViaEmail = $true
                SendConversationEmails = $true
            }


    $m = New-V1Asset Member -attri $member | Save-V1Asset 
    $memberOid = $m.ID

    $relativeUrl = 'ui.v1?gadget=%2fWidgets%2fLists%2fAdmin%2fMemberRoleProjectList%2fGadget'

    $payloadJson = @"
    {
            "gadget":"/Widgets/Lists/Admin/MemberRoleProjectList/Gadget",
            "Settings":{
                "UserDefinedSort":null,
                "NewFilter":{
                    "Expander":{
                        "IsExpanded":"False"
                    },
                    "SelectedMyFilterResolverKey":"Custom/WidgetsListsAdminMemberRoleProjectListNewFilter/SelectedMyFilter"
                },
                "Query":{
                    "CompanyFilterApplicators":{
                        "0":"Custom/WidgetsListsAdminMemberRoleProjectListQuery/ScopeCustomProjectHealth",
                        "1":"Custom/WidgetsListsAdminMemberRoleProjectListQuery/ScopeStatus",
                        "2":"Custom/WidgetsListsAdminMemberRoleProjectListQuery/ScopePlanningLevel",
                        "":"0,1,2"
                    },
                    "FindResolverKey":"Custom/WidgetsListsAdminMemberRoleProjectListQuery/FindValue",
                    "OrderByToken":null
                },
                "SelectAssetContext":null,
                "Expander":{
                    "IsExpanded":null
                },
                "MajorSort":"`$Column3",
                "SortOrder":null
            },
            "FirstRowIndex":0,
            "id":"_ergfatq",
            "ContextManager":{
                "PrimaryScopeContext": $ROOT_SCOPE,
                "ScopeRollup":true,
                "AssetContext": $memberOid,
                "AssetListContext":"",
                "Bubble": $memberOid,
                "ScopeLabel":"-"
            },"SelectedRow":{
                "selectedKey":"_v1_asset",
                "selected": $ROOT_SCOPE
            },
            "SaveRoles":[
                {
                    "memberoid": $memberOid,
                    "scopeoid": $ROOT_SCOPE,
                    "roleoid": $ADMIN_ROLE,
                    "onownerlist":false
                }
            ],
            "SaveAssets":null,
            "TreeState":{
                [$ROOT_SCOPE]: true
            }
    }
"@            
    $uri = "http://$(Get-V1BaseUri)/$relativeUrl"

    $null = InvokeApi -uri $uri -method POST -body $payloadJson
    Write-Information "Added user $MemberName"
}

end
{
    $InformationPreference = $prevPref

}

}

