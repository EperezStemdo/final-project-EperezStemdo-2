terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    # ansible = {
    #   version = "~> 1.3.0"
    #   source  = "ansible/ansible"
    # }
  }
  backend "azurerm" {
    resource_group_name   = "rg-eperez-dvfinlab"
    storage_account_name  = "staeperezdvfinlab"
    container_name        = "tfstateeperez"
    key                   = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}


#nsg
resource "azurerm_network_security_group" "nsg" {
  for_each            = var.sec_groups
  name                = each.key
  location = each.value.location
  resource_group_name            = each.value.resource_group_name 
  
  security_rule {
    name                       = each.value.rule_name 
    priority                   = each.value.priority
    direction                  = each.value.direction
    access                     = each.value.access
    protocol                   = each.value.protocol
    source_port_range          = each.value.source_port_range
    destination_port_range     = each.value.destination_port_range
    source_address_prefix      = each.value.source_address_prefix
    destination_address_prefix = each.value.destination_address_prefix
  }

}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
}

#subnets and association with nsg

resource "azurerm_subnet" "sn" {
  for_each            = var.subnets
  name                = each.key
  resource_group_name            = each.value.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = each.value.address_prefixes
  
}

resource "azurerm_subnet_network_security_group_association" "assoc_nsg" {
  for_each = var.subnets
  subnet_id = azurerm_subnet.sn[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.value.nsg_keys].id

}

#public IP

resource "azurerm_public_ip" "public_ip" {
  for_each            = var.public_ips
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  allocation_method   = each.value.allocation_method

  tags = {
    environment = "Production"
  }
}


#nics
resource "azurerm_network_interface" "nic" {
  for_each            = var.network_interfaces
  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  
  ip_configuration {
    name                          = "internal"
    subnet_id = azurerm_subnet.sn[each.value.subnet_keys].id
    private_ip_address_allocation = each.value.private_ip_address_allocation
    public_ip_address_id = azurerm_public_ip.public_ip[each.value.public_ip_keys].id  # Asociar IP pública a la interfaz de red
  }
}



#VM

resource "azurerm_linux_virtual_machine" "vm" {
 
  for_each            = var.virtual_machines

  name                = each.value.vm_name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  size                = each.value.size
  admin_username      = each.value.admin_username
  #disable_password_authentication = false
  #admin_password                  = each.value.admin_password

  network_interface_ids = [for interface_key in each.value.network_interface_keys : azurerm_network_interface.nic[interface_key].id]
  os_disk {
    caching              = each.value.caching
    storage_account_type = each.value.storage_account_type
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  admin_ssh_key {
    username   = each.value.admin_username
    public_key = file("C:/Users/eperez/.ssh/id_rsa.pub")
  }
}

#Ansible

# resource "ansible_host" "vmdbhost" {
#   name      = azurerm_virtual_machine.example.public_ip_address
#   groups    = ["vmdb"]
#   variables = {
#     ansible_user                 = "eperez"
#     ansible_ssh_private_key_file = file("C:/Users/eperez/.ssh/id_rsa.pub")
#     ansible_python_interpreter   = "/usr/bin/python3"
#   }
# }

#AKS
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "eperezAKS"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "AKSeperez"
  sku_tier = "Standard"

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_B2s"
    node_count = var.node_count
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}


#Azure container registry

resource "azurerm_container_registry" "acr" {
  name                = "eperezacr"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
}

