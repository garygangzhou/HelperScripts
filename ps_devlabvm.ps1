#########################################
#  Run ps_deblab_env.ps1 first
# change subnet name first

# Connect-AzAccount
# $mySub = "Visual Studio Enterprise Subscription - Gary Zhou"
# Set-AzContext -Subscription $mySub

$VMLocalAdminUser = "gzhou"
$VMLocalAdminSecurePassword = ConvertTo-SecureString "1q2w3e$R%T^Y" -AsPlainText -Force
$LocationName = "canadacentral"
$ResourceGroupName = "gz-grp-2024-01-10-13-54-29"
$ComputerName = "VM" + (Get-Date).ToString("yyMMddHHmmss")
$VMName = $ComputerName
$VMSize = "Standard_DS3"

$VnetName = "vnet-02"
$NICName = "NIC-" + $VMName
$SubnetName = "s1-vnet-02"
#$SubnetAddressPrefix = "10.0.0.0/24"
#$VnetAddressPrefix = "10.0.0.0/16"

#$SingleSubnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressPrefix
#$Vnet = New-AzVirtualNetwork -Name $NetworkName -ResourceGroupName $ResourceGroupName -Location $LocationName -AddressPrefix $VnetAddressPrefix -Subnet $SingleSubnet
$vnet = Get-AzVirtualNetwork -name $VnetName -ResourceGroupName $ResourceGroupName
$snet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $vnet

$NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $LocationName -SubnetId $snet.Id

$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);

$securityTypeStnd = "Standard"
$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize -SecurityType $securityTypeStnd
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2022-datacenter-azure-edition-core' -Version latest

New-AzVM -ResourceGroupName $ResourceGroupName -Location $LocationName -VM $VirtualMachine -Verbose
