# build a resource group, with 3 vnet
# Import-module Az.Accounts

Connect-AzAccount
$timestr = (Get-Date).ToString("yyyy-MM-dd-HH-mm-ss")

$mySub = "Visual Studio Enterprise Subscription - Gary Zhou"
$rg = "gz-grp-" + $timestr
$loc = "Canada Central"
$vn1 = "vnet-01"
$vn2 = "vnet-02"
$vn3 = "vnet-03"

Set-AzContext -Subscription $mySub

#new resource group
new-azresourcegroup -name $rg -location $loc

#new vnet
New-AzVirtualNetwork -name $vn1 -Location $loc -ResourceGroupName $rg -AddressPrefix "10.11.0.0/16"
New-AzVirtualNetwork -name $vn2 -Location $loc -ResourceGroupName $rg -AddressPrefix "10.12.0.0/16"
New-AzVirtualNetwork -name $vn3 -Location $loc -ResourceGroupName $rg -AddressPrefix "10.13.0.0/16"

#subnet
$vnobj1 = Get-AzVirtualNetwork -name $vn1 -ResourceGroupName $rg
Add-AzVirtualNetworkSubnetConfig -Name "s1-vnet-01" -VirtualNetwork $vnobj1 -AddressPrefix "10.11.1.0/24"
Add-AzVirtualNetworkSubnetConfig -Name "s2-vnet-01" -VirtualNetwork $vnobj1 -AddressPrefix "10.11.2.0/24"
Set-AzVirtualNetwork -VirtualNetwork $vnobj1

$vnobj2 = Get-AzVirtualNetwork -name $vn2 -ResourceGroupName $rg
Add-AzVirtualNetworkSubnetConfig -Name "s1-vnet-02" -VirtualNetwork $vnobj2 -AddressPrefix "10.12.1.0/24"
Add-AzVirtualNetworkSubnetConfig -Name "s2-vnet-02" -VirtualNetwork $vnobj2 -AddressPrefix "10.12.2.0/24"
Set-AzVirtualNetwork -VirtualNetwork $vnobj2

$vnobj3 = Get-AzVirtualNetwork -name $vn3 -ResourceGroupName $rg
Add-AzVirtualNetworkSubnetConfig -Name "s1-vnet-03" -VirtualNetwork $vnobj3 -AddressPrefix "10.13.1.0/24"
Add-AzVirtualNetworkSubnetConfig -Name "s2-vnet-03" -VirtualNetwork $vnobj3 -AddressPrefix "10.13.2.0/24"
Set-AzVirtualNetwork -VirtualNetwork $vnobj3

### clean up
# Remove-AzResourceGroup $rg -Force -Verbose

#  Disconnect-AzAccount

