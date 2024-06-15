# terraform {
#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = "~> 3.0"
#     }
#     random = {
#       source  = "hashicorp/random"
#       version = "~> 3.0"
#     }
#     azapi = {
#       source  = "azure/azapi"
#       version = "~> 1.0"
#     }
#   }

#   backend "azurerm" {
#     resource_group_name   = "rg-eperez-dvfinlab"
#     storage_account_name  = "staeperezdvfinlab"
#     container_name        = "tfstateeperez"
#     key                   = "terraform.tfstate"
#   }
# }

# provider "azurerm" {
#   features {}
# }

# provider "azapi" {
#   # Configure the azapi provider if necessary
# }

# provider "random" {
#   # No specific configuration needed for the random provider
# }



# resource "random_pet" "ssh_key_name" {
#   prefix    = "ssh"
#   separator = ""
# }

# resource "azapi_resource_action" "ssh_public_key_gen" {
#   type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
#   resource_id = azapi_resource.ssh_public_key.id
#   action      = "generateKeyPair"
#   method      = "POST"

#   response_export_values = ["publicKey", "privateKey"]
# }

# resource "azapi_resource" "ssh_public_key" {
#   type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
#   name      = random_pet.ssh_key_name.id
#   location  = var.location
#   parent_id = "/subscriptions/86f76907-b9d5-46fa-a39d-aff8432a1868/resourceGroups/rg-eperez-dvfinlab"
# }

# output "key_data" {
#   value = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
# }