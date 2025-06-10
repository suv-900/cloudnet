resource "azurerm_key_vault" "kv" {
  name                = var.kv_name
  resource_group_name = var.rg_name

  location = var.location
  sku_name = var.sku

  tenant_id = var.tenant_id
}

resource "azurerm_key_vault_access_policy" "access_policy" {
  tenant_id          = var.tenant_id
  object_id          = var.object_id
  key_vault_id       = azurerm_key_vault.kv.id
  secret_permissions = ["Get", "Set", "Delete", "Purge", "List", "Backup", "Recover", "Restore"]
}