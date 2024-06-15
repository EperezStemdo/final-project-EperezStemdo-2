location = "West Europe"
resource_group_name = "rg-eperez-dvfinlab"

#nsg

sec_groups = {
  nsg1 = {
    name = "epereznsgdb"
    location  = "West Europe"
    resource_group_name  = "rg-eperez-dvfinlab"
    rule_name = "AllowSSH"
    priority = 100
    direction = "Inbound" 
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
  nsg2 = {
    name = "epereznsgbackup"
    location = "West Europe"
    resource_group_name  = "rg-eperez-dvfinlab"
    rule_name = "AllowHTTP"
    priority = 101
    direction = "Inbound" 
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "80"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
  nsg3 = {
    name  = "epereznsgdbk8s"
    location = "West Europe"
    resource_group_name  = "rg-eperez-dvfinlab"
    rule_name = "AllowSSH"
    priority = 100
    direction = "Inbound" 
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}

#vnet
vnet_name = "vnetepereztfexercise"
vnet_address_space = ["10.0.0.0/16"]

#subnet

subnets = {
  sn1 = {
    name                       = "eperezsndb"
    resource_group_name                   = "rg-eperez-dvfinlab"
    virtual_network_name        = "vnetepereztfexercise"
    address_prefixes = ["10.0.1.0/24"]
    subnet_keys = "sn1"
    nsg_keys = "nsg1"
  }
  sn2 = {
    name                       = "eperezsnbackup"
    resource_group_name                   = "rg-eperez-dvfinlab"
    virtual_network_name        = "vnetepereztfexercise"
    address_prefixes = ["10.0.2.0/24"]
    subnet_keys = "sn2"
    nsg_keys = "nsg2"

  }
  sn3 = {
    name                       = "eperezsubnetk8s"
    resource_group_name                   = "rg-eperez-dvfinlab"
    virtual_network_name        = "vnetepereztfexercise"
    address_prefixes = ["10.0.3.0/24"]
    subnet_keys = "sn3"
    nsg_keys = "nsg3"
  }
}

#public ip

public_ips = {
  pi1 = {
    name                       = "eperezpublicip1"
    location                   = "West Europe"
    resource_group_name        = "rg-eperez-dvfinlab"
    allocation_method = "Static"
  }
  pi2 = {
    name                       = "eperezpublicip2"
    location                   = "West Europe"
    resource_group_name        = "rg-eperez-dvfinlab"
    allocation_method = "Static"
  }
}

#nic
network_interfaces = {
  nic1 = {
    name                       = "epereznicdb"
    location                   = "West Europe"
    resource_group_name        = "rg-eperez-dvfinlab"
    private_ip_address_allocation = "Dynamic"
    subnet_keys = "sn1"
    public_ip_keys = "pi1"
  }
  nic2 = {
    name                       = "epereznicbackup"
    location                   = "West Europe"
    resource_group_name        = "rg-eperez-dvfinlab"
    private_ip_address_allocation = "Dynamic"
    subnet_keys = "sn2"
    public_ip_keys = "pi2"
  }
}

#vm
 virtual_machines = {
  
    vm1 = {
      vm_name            = "eperezvmdb"
      resource_group_name = "rg-eperez-dvfinlab"
      location           = "West Europe"
      size               = "Standard_B1ms"
      admin_username     = "eperez"
      admin_password = "Eperez1234!"
      caching            = "ReadWrite"
      storage_account_type = "Standard_LRS"
     network_interface_keys = ["nic1"]
  }
  
    vm2 = {
      vm_name            = "eperezvmbackup"
      resource_group_name = "rg-eperez-dvfinlab"
      location           = "West Europe"
      size               = "Standard_B1ms"
      admin_username     = "eperez"
      admin_password = "Eperez1234!"
      caching            = "ReadWrite"
      storage_account_type = "Standard_LRS"
    network_interface_keys = ["nic2"]
    }
}