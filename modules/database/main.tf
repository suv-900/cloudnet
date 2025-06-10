resource "random_pet" "sql_username" {}

resource "random_password" "sql_password" {
  length = 20

  depends_on = [random_pet.sql_username]
}

resource "azurerm_mssql_server" "sql_server" {
  name                         = var.sql_server_name
  resource_group_name          = var.rg_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = random_pet.sql_username.id
  administrator_login_password = random_password.sql_password.result
  
  tags                         = var.tags
}

resource "azurerm_mssql_database" "sql_db" {
  name      = var.sql_db_name
  server_id = azurerm_mssql_server.sql.id
  sku_name  = var.sql_sku

  tags      = var.tags
}

resource "azurerm_key_vault_secret" "sql_username_secret" {
  name = var.secret_sql_username_name
  value = random_pet.sql_username.id
  key_vault_id = var.kv_id 
}

resource "azurerm_key_vault_secret" "sql_password_secret" {
  name = var.secret_sql_password_name
  value = random_password.sql_password.result
  key_vault_id = var.kv_id 
}