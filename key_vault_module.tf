data "azurerm_client_config" "current" {

}

output "account_id" {
  value = data.azurerm_client_config.current.client_id
}

resource "azurerm_key_vault" "myappkeyvault2" {
  name                        = "myappkeyvault2"
  location                    = azurerm_resource_group.myapp.location
  resource_group_name         = azurerm_resource_group.myapp.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name = "standard"
}

resource "azurerm_key_vault_access_policy" "myapp_config_policy" {
  key_vault_id = azurerm_key_vault.myappkeyvault2.id
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_user_assigned_identity.myapp-mi.principal_id

  # Define the permissions for the access policy
  secret_permissions  = ["Get", "List", ]
  key_permissions     = ["Get", "List", ]
  storage_permissions = ["Get", "List", ]
}

