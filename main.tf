# read the existing Resource group #
data "azurerm_resource_group" "rsg" {
    name = "demo-RSG"
}

# refer to the existing Subnet #
data "azurerm_subnet" "frontend" {
name = "frontend"
resource_group_name = data.azurerm_resource_group.rsg.name
virtual_network_name = "demo-Vnet"
}

data "azurerm_availability_set" "avset" {
    name = "AVset01"
    resource_group_name = data.azurerm_resource_group.rsg.name
}

# create Public IP #
resource "azurerm_public_ip" "pip" {
    name = "VM_pip"
    location = data.azurerm_resource_group.rsg.location
    resource_group_name = data.azurerm_resource_group.rsg.name
    allocation_method = "Static"
    idle_timeout_in_minutes = 4
}

# Create Network security Group #
resource "azurerm_network_security_group" "NSG" {
    name = "VM_NSG"
    location = data.azurerm_resource_group.rsg.location
    resource_group_name = data.azurerm_resource_group.rsg.name
}

# Create Network security Rule #
resource "azurerm_network_security_rule" "name" {
    name = "RDP_rule"
    resource_group_name = data.azurerm_resource_group.rsg.name
    network_security_group_name = azurerm_network_security_group.NSG.name
    access = "Allow"
    destination_address_prefix = "*"
    source_address_prefix = "*"
    destination_port_range = 3389
    source_port_range = "*"
    direction = "Inbound"
    protocol = "Tcp"
    priority = 120
    description = "Allow RDP connection to virtual machine"
}

# Create NIC card for VM #
resource "azurerm_network_interface" "NIC" {
    name = "NIC-VM01"
    location = data.azurerm_resource_group.rsg.location
    resource_group_name = data.azurerm_resource_group.rsg.name
    ip_configuration {
      name = "ipconfig"
      public_ip_address_id = azurerm_public_ip.pip.id
      subnet_id = data.azurerm_subnet.frontend.id
      private_ip_address_allocation = "dynamic"

    }
}

# Associating NIC card with NSG #
resource "azurerm_network_interface_security_group_association" "NIC_associate_NSG" {
    network_interface_id = azurerm_network_interface.NIC.id
    network_security_group_id = azurerm_network_security_group.NSG.id  
}

# Creating Virtual machine #
resource "azurerm_virtual_machine" "vm" {
  name = "VM01"
  location = data.azurerm_resource_group.rsg.location
  resource_group_name = data.azurerm_resource_group.rsg.name
  vm_size = "Standard_DS2_v2"
  availability_set_id = data.azurerm_availability_set.avset.id
  network_interface_ids = [ azurerm_network_interface.NIC.id ]

  os_profile {
    admin_username = var.admin_username
    admin_password = var.admin_pwd
    computer_name = "VM01"
  }

delete_os_disk_on_termination = true
    storage_os_disk {
      name = "OS_disk"
      create_option = "fromimage"
      caching = "readwrite"
    }

delete_data_disks_on_termination = true
    storage_data_disk {
        name = "datadisk01"
        create_option = "Empty"
        disk_size_gb = 1
        lun = 1
        managed_disk_type = "Standard_LRS"

    }

    
    storage_image_reference {
      publisher = "Microsoftwindowsserver"
      offer = "windowsserver"
      sku = "2016-datacenter"
      version = "latest"

    }

    os_profile_windows_config {
      provision_vm_agent = false
    }
}
