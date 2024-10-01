resource "azurerm_storage_account" "myapp" {
  name                = "myappdata0930"
  resource_group_name = azurerm_resource_group.myapp.name
  location                 = azurerm_resource_group.myapp.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    environment = "staging"
  }
}


# Define private endpoint for Blob service
resource "azurerm_private_endpoint" "blob" {
  name                = "myapp-pe-blob"
  location            = azurerm_resource_group.myapp.location
  resource_group_name = azurerm_resource_group.myapp.name
  subnet_id           = azurerm_subnet.myapp_pool_1.id

  private_service_connection {
    name                           = "blob-private-connection"
    private_connection_resource_id = azurerm_storage_account.myapp.id
    subresource_names              = ["blob"]  # Indicates that the endpoint is for blob service
    is_manual_connection           = false
  }
}

# Define private endpoint for DFS service
resource "azurerm_private_endpoint" "dfs" {
  name                = "myapp-pe-dfs"
  location            = azurerm_resource_group.myapp.location
  resource_group_name = azurerm_resource_group.myapp.name
  subnet_id           = azurerm_subnet.myapp_pool_1.id

  private_service_connection {
    name                           = "dfs-private-connection"
    private_connection_resource_id = azurerm_storage_account.myapp.id
    subresource_names              = ["dfs"]  # Indicates that the endpoint is for dfs service (Data Lake Storage)
    is_manual_connection           = false
  }
}

# Define private endpoint for File service
resource "azurerm_private_endpoint" "file" {
  name                = "myapp-pe-file"
  location            = azurerm_resource_group.myapp.location
  resource_group_name = azurerm_resource_group.myapp.name
  subnet_id           = azurerm_subnet.myapp_pool_1.id

  private_service_connection {
    name                           = "file-private-connection"
    private_connection_resource_id = azurerm_storage_account.myapp.id
    subresource_names              = ["file"]  # Indicates that the endpoint is for file service
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.myapp.name
}

resource "azurerm_private_dns_a_record" "myapp" {
  name                = azurerm_storage_account.myapp.name
  zone_name           = azurerm_private_dns_zone.blob.name
  resource_group_name = azurerm_resource_group.myapp.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.blob.private_service_connection[0].private_ip_address]
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "myapp-blob-link"
  resource_group_name   = azurerm_resource_group.myapp.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.myapp.id
}
