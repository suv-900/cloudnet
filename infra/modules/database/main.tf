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
}

resource "azurerm_mssql_firewall_rule" "fwr1" {
  name             = var.mssql_firewall_rule_name
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"

  depends_on = [azurerm_mssql_server.sql_server]
}

resource "azurerm_mssql_database" "sql_db" {
  server_id = azurerm_mssql_server.sql_server.id
  name      = var.sql_db_name
  sku_name  = var.sql_sku

  depends_on = [azurerm_mssql_firewall_rule.fwr1]
}

resource "azurerm_key_vault_secret" "sql_username_secret" {
  name         = var.secret_sql_username_name
  value        = random_pet.sql_username.id
  key_vault_id = var.kv_id

  depends_on = [azurerm_mssql_database.sql_db]
}

resource "azurerm_key_vault_secret" "sql_password_secret" {
  name         = var.secret_sql_password_name
  value        = random_password.sql_password.result
  key_vault_id = var.kv_id

  depends_on = [azurerm_key_vault_secret.sql_username_secret]
}

resource "azurerm_key_vault_secret" "sql_connection_string" {
  name = var.secret_sql_connection_string_name
  value = format(
    "Server=tcp:%s,1433;Initial Catalog=%s;Persist Security Info=False;User ID=%s;Password=%s;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;",
    azurerm_mssql_server.sql_server.fully_qualified_domain_name,
    azurerm_mssql_database.sql_db.name,
    random_pet.sql_username.id,
    random_password.sql_password.result
  )
  key_vault_id = var.kv_id

  depends_on = [azurerm_key_vault_secret.sql_password_secret]
}

resource "azurerm_key_vault_secret" "sql_server_fqdn" {
  name         = var.secret_sql_server_fqdn_name
  value        = azurerm_mssql_server.sql_server.fully_qualified_domain_name
  key_vault_id = var.kv_id

  depends_on = [azurerm_key_vault_secret.sql_connection_string]
}

resource "azurerm_key_vault_secret" "sql_database_name" {
  name         = var.secret_sql_database_name
  value        = azurerm_mssql_database.sql_db.name
  key_vault_id = var.kv_id

  depends_on = [azurerm_key_vault_secret.sql_server_fqdn]
}

