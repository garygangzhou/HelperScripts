
$sub_name = "Visual Studio Enterprise Subscription - Gary Zhou"
#$sub_name = "sub-CCO-NonPHI-UMAProd-001"
#$sub_name = "sub-DS-NonPHI-IPCCONSENT-001"

## log in
Write-Host "login to subscription $($sub_name)"
Connect-AzAccount -Subscription $sub_name
# Disconnect-AzAccount

#Write-Host "get list of resource group"
#Get-AzResourceGroup | select-object ResourceGroupName, Location

#$user = Get-AzADUser -UserPrincipalName "sarwar.nadeem@ontariohealth.ca"
$user = Get-AzADUser -UserPrincipalName "gary.zhou@ontariohealth.ca"
$objectId = $user.Id
Write-Output "==> user id $($objectId)"
$roleAssignments = Get-AzRoleAssignment -ObjectId $objectId
# Display role assignments
Write-Output "==> there are $($roleAssignments.length) role assignment found."
foreach ($assignment in $roleAssignments) {
    Write-Output "Role: $($assignment.RoleDefinitionName)"
    Write-Output "Scope: $($assignment.Scope)"
    Write-Output "-----------------------------------"
}


# $roleAssignments = Get-AzRoleAssignment 
#         -ResourceGroupName $resourceGroupName 
#         -ResourceName $resourceName 
#         -ResourceType $resourceType

#         # Display role assignments
# foreach ($assignment in $roleAssignments) {
#     Write-Output "Role: $($assignment.RoleDefinitionName)"
#     Write-Output "Principal: $($assignment.PrincipalName)"
#     Write-Output "Principal Type: $($assignment.PrincipalType)"
#     Write-Output "Scope: $($assignment.Scope)"
#     Write-Output "-----------------------------------"
# }
