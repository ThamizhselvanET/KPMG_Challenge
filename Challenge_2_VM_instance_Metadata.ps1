
# Install Azure PowerShell module if not already installed 
if (-not (Get-Module -Name Az -ListAvailable)) 
{ 
Install-Module -Name Az -AllowClobber -Scope CurrentUser -Force 
} 
# Connect to Azure account (you may need to sign in) 
Connect-AzAccount 
#Set Context for the Azure Sandbox Subscription
Set-AzContext "PG-Sandbox-01"

# Get the metadata of the Azure VM 
$vm = Get-AzVM -ResourceGroupName "sandbox_rg" -Name "testVM" 

# Create a custom object to store the metadata 
$metadata = [PSCustomObject]@{ 
    VMName = $vm.Name 
    Location = $vm.Location 
    VMSize = $vm.HardwareProfile.VmSize 
    ProvisioningState = $vm.ProvisioningState 
    OperatingSystem = $vm.StorageProfile.OsDisk.OsType 
    ManagedOSDisk = $vm.StorageProfile.OsDisk.ManagedDisk.Id 
    DataDisks = @($vm.StorageProfile.DataDisks.Id) 
    NetworkInterfaces = @($vm.NetworkProfile.NetworkInterfaces.Id) 
    Tags = $vm.Tags 
} 

# Convert the custom object to JSON 
$jsonOutput = $metadata | ConvertTo-Json -Depth 4 

# Output the JSON 
$jsonOutput 
