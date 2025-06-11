provider "azurerm" {
  features {}
}

data "azurerm_client_config" "client_config" {}

resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
}

module "kv" {
  source = "./modules/keyvault"

  kv_name  = local.keyvault_name
  rg_name  = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  sku      = var.kv_sku

  tenant_id = data.azurerm_client_config.client_config.tenant_id
  object_id = data.azurerm_client_config.client_config.object_id
}

module "db" {
  source = "./modules/database"

  rg_name  = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location

  sql_server_name = local.sql_server_name
  sql_db_name     = local.sql_db_name
  kv_id           = module.kv.kv_id
  sql_sku         = var.sql_sku

  secret_sql_username_name          = local.secret_sql_username_name
  secret_sql_password_name          = local.secret_sql_password_name
  secret_sql_connection_string_name = local.secret_sql_connection_string_name
  secret_sql_database_name          = local.secret_sql_database_name
  secret_sql_server_fqdn_name       = local.secret_sql_server_fqdn_name

  #name con_url and server_url
  depends_on = [module.kv]
}

module "acr" {
  source = "./modules/acr"

  rg_name  = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location

  acr_name = local.acr_name
  acr_sku  = var.acr_sku

  depends_on = [module.db]
}

data "azurerm_key_vault_secret" "sql_username" {
  name         = local.secret_sql_username_name
  key_vault_id = module.kv.kv_id
  
  depends_on = [module.acr]
}

data "azurerm_key_vault_secret" "sql_password" {
  name         = local.secret_sql_password_name
  key_vault_id = module.kv.kv_id
  depends_on = [data.azurerm_key_vault_secret.sql_username]
}

data "azurerm_key_vault_secret" "server_fqdn" {
  name         = local.secret_sql_server_fqdn_name
  key_vault_id = module.kv.kv_id
  depends_on = [data.azurerm_key_vault_secret.sql_password]
}

data "azurerm_key_vault_secret" "database_name" {
  name         = local.secret_sql_database_name
  key_vault_id = module.kv.kv_id
  depends_on = [data.azurerm_key_vault_secret.server_fqdn]
}

module "webapp" {
  source   = "./modules/webapp"
  rg_name  = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location

  service_plan_name = local.asp_name
  service_plan_sku  = var.service_plan_sku
  webapp_name       = local.app_name
  node_version      = var.node_version

  secure_envvars = {
    "SQL_USER"     = data.azurerm_key_vault_secret.sql_username.value
    "SQL_PASSWORD" = data.azurerm_key_vault_secret.sql_password.value
    "SQL_SERVER"   = data.azurerm_key_vault_secret.server_fqdn.value
    "SQL_DATABASE" = data.azurerm_key_vault_secret.database_name.value
  }

  depends_on = [
    data.azurerm_key_vault_secret.database_name,
    data.azurerm_key_vault_secret.server_fqdn,
    data.azurerm_key_vault_secret.sql_password,
    data.azurerm_key_vault_secret.sql_username
  ]
}

module "aks" {
  source = "./modules/aks"

  aks_cluster_name = local.aks_name
  rg_name          = azurerm_resource_group.rg.name
  location         = azurerm_resource_group.rg.location
  dns_prefix       = local.dns_prefix

  system_node_pool_name       = var.system_node_pool_name
  system_node_pool_node_count = var.system_node_pool_node_count
  system_node_pool_vm_size    = var.system_node_pool_vm_size

  acr_id       = module.acr.acr_id
  tenant_id    = data.azurerm_client_config.client_config.tenant_id
  key_vault_id = module.kv.kv_id

  depends_on = [module.webapp]
}


