################################ Azure CLI #############################################
az login

az logout

az account list

#set to work with a subscription
az account set --subscription "subscription name"
az account show

################################ Az Powershell #############################################
# F8 to run
write-host "hello word"

#install Az Powershell
#get current powershell version
$PSVersionTable.PSVersion

Get-Module -ListAvailable az
Get-Module -Name AzureRm -ListAvailable
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# install Az Powershell module
Install-Module -Name Az -Repository PSGallery -Force

#
Get-AzureRmResourceProvider -providernamespace Microsoft.Cdn

#connect to azure
Connect-AzAccount
Disconnect-AzAccount

Get-AzSubscription
Set-AzContext -Subscription "Visual Studio Enterprise Subscription - Gary Zhou"

#resource group
Get-AzResourceGroup | Select-Object ResourceGroupName, Location

New-AzResourceGroup -name "psgrp01" -location "Canada Central" 

Remove-AzResourceGroup -name "psgrp"

#list resource group name
$rgs = Get-AzResourceGroup
foreach ($rg in $rgs.ResourceGroupName)
{
    Write-Host $rg
}


### network watcher, diagnoise network connection
$nw = Get-AzResource | Where-Object {$_.ResourceType -eq "Microsoft.Network/networkWatchers" -and $_.Location -eq "CanadaCentral" } 
$networkWatcher = Get-AzNetworkWatcher -Name $nw.Name -ResourceGroupName $nw.ResourceGroupName 

$VM = Get-AzVM -ResourceGroupName GaryZhou-Grp -Name vm-02 
$Nics = Get-AzNetworkInterface | Where-Object { $vm.NetworkProfile.NetworkInterfaces.Id -contains $_.Id }

Test-AzNetworkWatcherIPFlow -NetworkWatcher $networkWatcher -TargetVirtualMachineId $VM.Id -Direction Outbound -Protocol TCP `
-LocalIPAddress $nics[0].IpConfigurations[0].PrivateIpAddress -LocalPort 801 -RemoteIPAddress 4.205.186.254 -RemotePort 801


$newtags = @{"Dept"="mydept"; "Status"="Normal"}
$rgs = Get-AzResourceGroup -Name psgrp01
Set-AzResourceGroup -Tag $newtags -Name psgrp01

$tags = $rgs.Tags
$tags.Add("Env", "Dev")
Set-AzResourceGroup -Tag $tags -Name psgrp01



################## Create a web site ##############################
Import-module Az.Accounts
Connect-AzAccount
Disconnect-AzAccount

Get-AzSubscription
$mySub = "Visual Studio Enterprise Subscription - Gary Zhou"
Set-AzContext -Subscription $mySub

#resource group
Get-AzResourceGroup | Select-Object ResourceGroupName, Location
$resourcegroup = "GaryZhou-Grp"
$appServiceName = "GaryAppService"
$appServicePlanName = "GaryAppService-plan"
$location = "Canada Central"
$sku = "Basic"
$appServicePlan = New-AzAppServicePlan -ResourceGroupName $resourcegroup -Name $appServicePlanName -location $location -Tier $sku

import-module AzureRM.Websites
$website = New-AzureRmWebApp -ResourceGroupName $resourcegroup -Name $appServiceName -Location $location -AppServicePlan $appServicePlan



###################################################
$rg = "gz-grp"
$lo = "Canada Central"
$vn1 = "vnet-01"
$vn2 = "vnet-02"
$vn3 = "vnet-03"
$vm1 = "vm-01"
$vm2 = "vm-02"
$vm3 = "vm-03"
#new resource group
new-azresourcegroup -name $rg -location $lo
$rgobj = get-azresourcegroup -name $rg

#new vnet
New-AzVirtualNetwork -name $vn1 -Location $lo -ResourceGroupName $rg -AddressPrefix "10.10.0.0/16"
New-AzVirtualNetwork -name $vn2 -Location $lo -ResourceGroupName $rg -AddressPrefix "10.11.0.0/16"
New-AzVirtualNetwork -name $vn3 -Location $lo -ResourceGroupName $rg -AddressPrefix "10.12.0.0/16"

$vnobj1 = Get-AzVirtualNetwork -name $vn1
$vnobj2 = Get-AzVirtualNetwork -name $vn2
$vnobj3 = Get-AzVirtualNetwork -name $vn3

#subnet
Add-AzVirtualNetworkSubnetConfig -Name "s1-vnet-01" -VirtualNetwork $vnobj1 -AddressPrefix "10.10.1.0/24"
Add-AzVirtualNetworkSubnetConfig -Name "s2-vnet-01" -VirtualNetwork $vnobj1 -AddressPrefix "10.10.2.0/24"
Set-AzVirtualNetwork -VirtualNetwork $vnobj1

Add-AzVirtualNetworkSubnetConfig -Name "s1-vnet-02" -VirtualNetwork $vnobj2 -AddressPrefix "10.11.1.0/24"
Add-AzVirtualNetworkSubnetConfig -Name "s2-vnet-02" -VirtualNetwork $vnobj2 -AddressPrefix "10.11.2.0/24"
Set-AzVirtualNetwork -VirtualNetwork $vnobj2

Add-AzVirtualNetworkSubnetConfig -Name "s1-vnet-03" -VirtualNetwork $vnobj3 -AddressPrefix "10.12.1.0/24"
Add-AzVirtualNetworkSubnetConfig -Name "s2-vnet-03" -VirtualNetwork $vnobj3 -AddressPrefix "10.12.2.0/24"
Set-AzVirtualNetwork -VirtualNetwork $vnobj3


$nw = Get-AzResource | Where-Object {$_.ResourceType -eq "Microsoft.Network/networkWatchers" -and $_.Location -eq "CanadaCentral" } 
$networkWatcher = Get-AzNetworkWatcher -Name $nw.Name -ResourceGroupName $nw.ResourceGroupName 

$VM = Get-AzVM -ResourceGroupName $rg -Name $vm1 
$Nics = Get-AzNetworkInterface | Where-Object { $vm.NetworkProfile.NetworkInterfaces.Id -contains $_.Id }

Test-AzNetworkWatcherIPFlow -NetworkWatcher $networkWatcher -TargetVirtualMachineId $VM.Id -Direction Outbound -Protocol TCP `
-LocalIPAddress $nics[0].IpConfigurations[0].PrivateIpAddress -LocalPort 3389 -RemoteIPAddress 10.11.1.4 -RemotePort 3389



