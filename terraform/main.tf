terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
 
     tls = {
      source  = "hashicorp/tls"
      version = "~> 3.0"
    }
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


#nsg
resource "azurerm_network_security_group" "nsg" {
  for_each            = var.sec_groups
  name                = each.key
  location = each.value.location
  resource_group_name            = each.value.resource_group_name 
  
   security_rule {
    name                       = "Allowapp"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allowmysql"
    priority                   = 1201
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allowssh"
    priority                   = 1101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
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
    #public_ip_address_id = azurerm_public_ip.public_ip[each.value.public_ip_keys].id  # Asociar IP pública a la interfaz de red
    public_ip_address_id = each.value.public_ip_enabled ? azurerm_public_ip.public_ip["pi1"].id : null
  

  }
}


resource "azurerm_network_interface_security_group_association" "nicassoc1" {
  network_interface_id    = azurerm_network_interface.nic["nic1"].id
  network_security_group_id = azurerm_network_security_group.nsg["nsg1"].id
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nicassoc2" {
  network_interface_id    = azurerm_network_interface.nic["nic2"].id
  network_security_group_id = azurerm_network_security_group.nsg["nsg1"].id
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

  #network_interface_ids = [for interface_key in each.value.network_interface_keys : azurerm_network_interface.nic[interface_key].id]
  #network_interface_ids = [azurerm_network_interface.nic[each.value.network_interface_keys].id]
  network_interface_ids = [for key in each.value.network_interface_keys : azurerm_network_interface.nic[key].id]

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
    public_key = file("./id_rsa.pub")
  }

    custom_data = each.value.custom_data_enabled ? base64encode(local.custom_data) : null

}


#AKS
resource "azurerm_kubernetes_cluster" "aks" {

  name                = "eperezAKS"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "bootcampaks"
  sku_tier = "Standard"

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_B2s"
    node_count = var.node_count
    vnet_subnet_id  = azurerm_subnet.sn["sn3"].id
  }

    network_profile {
    network_plugin = "azure"
    service_cidr   = "10.0.4.0/24"  
    dns_service_ip = "10.0.4.10"
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


locals {
  custom_data = <<EOF
#cloud-config
runcmd:
- [mkdir, '/actions-runner']
- [cd, '/actions-runner']
- [curl, '-o', 'actions-runner-linux-x64-2.317.0.tar.gz', '-L', 'https://github.com/actions/runner/releases/download/v2.317.0/actions-runner-linux-x64-2.317.0.tar.gz']
- [tar, '-xzf', 'actions-runner-linux-x64-2.317.0.tar.gz']
- [chmod, '-R', '777', '/actions-runner']
- [su, 'eperez', '-c', '/actions-runner/config.sh --url https://github.com/stemdo-labs/final-project-EperezStemdo-2 --token BHVSGAIQFNQYPSPYWJEXXKDGOG3KQ' ]
- ['./svc.sh', 'install']
- ['./svc.sh', 'start']
- [rm, '/actions-runner/actions-runner.tar.gz']
EOF
}


#su, 'eperez', '-c', '/actions-runner/config.sh --url https://github.com/stemdo-labs/final-project-EperezStemdo-2 --token BHVSGAJMCAMVPR4AB5LCLFLGN7YMO' --> This runner will have the following labels: 'self-hosted', 'Linux', 'X64'
# Enter any additional labels (ex. label-1,label-2): [press Enter to skip]
# A runner exists with the same name
# Would you like to replace the existing runner? (Y/N) [press Enter for N] Enter the name of runner: [press Enter for eperezvmdb]


#echo "Y" | su eperez -c "/actions-runner/config.sh --url https://github.com/stemdo-labs/final-project-EperezStemdo-2 --token BHVSGAJMCAMVPR4AB5LCLFLGN7YMO"
# echo "Y" | su eperez -c "/actions-runner/config.sh --url https://github.com/stemdo-labs/final-project-EperezStemdo-2 --token BHVSGAJMCAMVPR4AB5LCLFLGN7YMO --name eperezvmdb --replace": not found


#echo "Y" | bash -c "/actions-runner/config.sh --url https://github.com/stemdo-labs/final-project-EperezStemdo-2 --token BHVSGAJMCAMVPR4AB5LCLFLGN7YMO"
#echo "Y" | bash -c "/actions-runner/config.sh --url https://github.com/stemdo-labs/final-project-EperezStemdo-2 --token BHVSGAJMCAMVPR4AB5LCLFLGN7YMO": not found







