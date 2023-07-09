# Install Azure PowerShell module if not already installed 
if (-not (Get-Module -Name Az -ListAvailable)) 
{ 
Install-Module -Name Az -AllowClobber -Scope CurrentUser -Force 
}
 
# Connect to Azure Cloud
Connect-AzAccount 

# Create a resource group
$resourceGroupName = "YourResourceGroupName" 
$location = "YourLocation" 
New-AzResourceGroup -Name $resourceGroupName -Location $location 

# Create a virtual network
$vnetName = "YourVNetName" 
$vnetAddressPrefix = "10.0.0.0/16" 
$subnetName = "YourSubnetName" 
$subnetAddressPrefix = "10.0.0.0/24" 
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vnetName -AddressPrefix $vnetAddressPrefix -Location $location 
$subnet = Add-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $subnetAddressPrefix -VirtualNetwork $vnet 
Set-AzVirtualNetwork -VirtualNetwork $vnet 

# Create a public IP address for the load balancer
$publicIpName = "YourPublicIpName" 
$publicIpSku = "Standard" 
$publicIp = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Name $publicIpName -Sku $publicIpSku -Location $location -AllocationMethod Static 

# Create a load balancer
$loadBalancerName = "YourLoadBalancerName" 
$frontendIpConfigName = "YourFrontendIpConfigName" 
$backendAddressPoolName = "YourBackendAddressPoolName" 
$probeName = "YourProbeName" 
$loadBalancingRuleName = "YourLoadBalancingRuleName" 
$frontendIpConfig = New-AzLoadBalancerFrontendIpConfig -Name $frontendIpConfigName -PublicIpAddress $publicIp 
$backendAddressPool = New-AzLoadBalancerBackendAddressPoolConfig -Name $backendAddressPoolName 
$probe = New-AzLoadBalancerProbeConfig -Name $probeName -Protocol Http -Port 80 -IntervalInSeconds 15 -ProbeCount 2 
$rule = New-AzLoadBalancerRuleConfig -Name $loadBalancingRuleName -Protocol Tcp -FrontendIpConfiguration $frontendIpConfig -BackendAddressPool $backendAddressPool -Probe $probe -FrontendPort 80 -BackendPort 80 
New-AzLoadBalancer -ResourceGroupName $resourceGroupName -Name $loadBalancerName -Location $location -FrontendIpConfiguration $frontendIpConfig -BackendAddressPool $backendAddressPool -Probe $probe -LoadBalancingRule $rule 

# Create virtual machines for each tier (Web, Application, Database)
$vmNameWeb = "WebappVMName" 
$vmNameApp = "AppVMName" 
$vmNameDb = "DbVMName" 
$vmSize = "Standard_DS2_v2" 
$adminUsername = "Admin123" 
$adminPassword = "*******" 
$imagePublisher = "MicrosoftWindowsServer" 
$imageOffer = "WindowsServer" 
$imageSku = "2019-Datacenter" 
$subnetId = $vnet.Subnets[0].Id 
$vmConfigWeb = New-AzVMConfig -VMName $vmNameWeb -VMSize $vmSize 
$vmConfigApp = New-AzVMConfig -VMName $vmNameApp -VMSize $vmSize 
$vmConfigDb = New-AzVMConfig -VMName $vmNameDb -VMSize $vmSize 
$vmConfigWeb = Set-AzVMOperatingSystem -VM $vmConfigWeb -Windows -ComputerName $vmNameWeb -Credential (Get-Credential -UserName $adminUsername -Password $adminPassword) 
$vmConfigApp = Set-AzVMOperatingSystem -VM $vmConfigApp -Windows -ComputerName $vmNameApp -Credential (Get-Credential -UserName $adminUsername -Password $adminPassword) 
$vmConfigDb = Set-AzVMOperatingSystem -VM $vmConfigDb -Windows -ComputerName $vmNameDb -Credential (Get-Credential -UserName $adminUsername -Password $adminPassword) 
$vmConfigWeb = Add-AzVMNetworkInterface -VM $vmConfigWeb -Id $subnetId 
$vmConfigApp = Add-AzVMNetworkInterface -VM $vmConfigApp -Id $subnetId 
$vmConfigDb = Add-AzVMNetworkInterface -VM $vmConfigDb -Id $subnetId 
$vmConfigWeb = Set-AzVMSourceImage -VM $vmConfigWeb -PublisherName $imagePublisher -Offer $imageOffer -Skus $imageSku -Version "latest" 
$vmConfigApp = Set-AzVMSourceImage -VM $vmConfigApp -PublisherName $imagePublisher -Offer $imageOffer -Skus $imageSku -Version "latest" 
$vmConfigDb = Set-AzVMSourceImage -VM $vmConfigDb -PublisherName $imagePublisher -Offer $imageOffer -Skus $imageSku -Version "latest" 
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfigWeb 
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfigApp 
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfigDb 
