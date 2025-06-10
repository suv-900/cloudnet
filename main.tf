provider "azurerm" {
  features {}
}

data "azurerm_client_config" "client_config" {}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

module "kv" {
  source = "./modules/keyvault"

  kv_name  = var.keyvault_name
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

  sql_server_name = var.sql_server_name
  sql_db_name     = var.sql_db_name
  kv_id           = module.kv.kv_id
  sql_sku         = var.sql_sku
  
  secret_sql_username_name = var.secret_sql_username_name
  secret_sql_password_name = var.secret_sql_password_name

  depends_on = [module.kv ]
}

module "acr" {
  source = "./modules/acr"

  rg_name  = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  
  acr_name = var.acr_name
  acr_sku  = var.acr_sku

  depends_on = [module.db]
}

module "webapp" {
  source = "./modules/webapp"
  rg_name           = azurerm_resource_group.rg.name
  location          = azurerm_resource_group.rg.location

  service_plan_name = var.service_plan_name
  service_plan_sku  = var.service_plan_sku
  webapp_name       = var.webapp_name

  depends_on = [ module.acr ]
}

module "aks" {
  source = "./modules/aks"

  aks_cluster_name = var.aks_name
  rg_name          = azurerm_resource_group.rg.name
  location         = azurerm_resource_group.rg.location
  dns_prefix       = var.dns_prefix

  system_node_pool_name       = var.system_node_pool_name
  system_node_pool_node_count = var.system_node_pool_node_count
  system_node_pool_vm_size    = var.system_node_pool_vm_size

  acr_id       = module.acr.acr_id
  tenant_id    = data.azurerm_client_config.client_config.tenant_id
  key_vault_id = module.kv.kv_id

  depends_on = [ module.webapp]
}


