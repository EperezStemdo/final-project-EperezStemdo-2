variable "location" {
    type = string
}

variable "resource_group_name" {
    type = string   
}

#nsg

# variable "namenetgroupdb" {
#     type = string
# }

# variable "namenetgroupbackup" {
#     type = string
# }

# variable "namenetgroupk8s" {
#     type = string
# }

variable "sec_groups" {
  type = map(object({
    name                         = string
    location                     = string
    resource_group_name          = string
    rule_name = string
    priority = string
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
}

#vnet

variable "vnet_name" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}




#subnets

variable "subnets" {
  type = map(object({
    name = string
    resource_group_name = string
    virtual_network_name = string
    address_prefixes = list(string)
    subnet_keys = string
    nsg_keys = string
  }))
}

#public ip

variable "public_ips" {
  type = map(object({
    name = string
    resource_group_name  = string
    location          = string
    allocation_method = string

  }))
}

#nic

variable "network_interfaces" {
  type = map(object({
    name                         = string
    location                     = string
    resource_group_name          = string
    private_ip_address_allocation = string
    subnet_keys = string
    public_ip_keys = string

  }))
}

#MV

variable "virtual_machines" {
  type = map(object({
    vm_name            = string
    resource_group_name = string
    location           = string
    size               = string
    admin_username     = string
    admin_password = string
    caching            = string
    storage_account_type = string 
    network_interface_keys = list(string)
  }))
}

#aks

variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "node_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool."
  default     = 2
}

variable "msi_id" {
  type        = string
  description = "The Managed Service Identity ID. Set this value if you're running this example using Managed Identity as the authentication method."
  default     = null
}

variable "username" {
  type        = string
  description = "The admin username for the new cluster."
  default     = "azureadmin"
}


  

 