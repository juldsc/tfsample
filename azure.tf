# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Terraform configuration

import {
  to = azurerm_resource_group.myapp
  id = "/subscriptions/d37b65a7-482a-4b66-91c7-16d0a9c6903c/resourceGroups/${var.rg_name}"
}

resource "azurerm_resource_group" "myapp" {
  name     = var.rg_name
  location = var.location
}

import {
  to = azurerm_virtual_network.myapp
  id = "/subscriptions/d37b65a7-482a-4b66-91c7-16d0a9c6903c/resourceGroups/${var.rg_name}/providers/Microsoft.Network/virtualNetworks/core-vnet"
}

resource "azurerm_virtual_network" "myapp" {
  name                = "core-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.myapp.location
  resource_group_name = azurerm_resource_group.myapp.name
}

import {
  to = azurerm_subnet.myapp_pool_1
  id = "/subscriptions/d37b65a7-482a-4b66-91c7-16d0a9c6903c/resourceGroups/myapp/providers/Microsoft.Network/virtualNetworks/core-vnet/subnets/myapp_pool_1"
}

resource "azurerm_subnet" "myapp_pool_1" {
  name                 = "myapp_pool_1"
  resource_group_name  = azurerm_resource_group.myapp.name
  virtual_network_name = azurerm_virtual_network.myapp.name
  address_prefixes     = ["10.0.1.0/24"]
  enforce_private_link_endpoint_network_policies = true
}

import {
  to = azurerm_user_assigned_identity.myapp-mi
  id = "/subscriptions/d37b65a7-482a-4b66-91c7-16d0a9c6903c/resourceGroups/myapp/providers/Microsoft.ManagedIdentity/userAssignedIdentities/myapp-mi"
}

resource "azurerm_user_assigned_identity" "myapp-mi" {
  location            = azurerm_resource_group.myapp.location
  name                = "myapp-mi"
  resource_group_name = azurerm_resource_group.myapp.name
}


