provider "azurerm" {
  features {}
}

data "azurerm_client_config" "client_config" {}

resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location

  tags = var.tags
}

module "kv" {
  source = "./modules/keyvault"

  kv_name  = local.keyvault_name
  rg_name  = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  sku      = var.kv_sku

  tenant_id = data.azurerm_client_config.client_config.tenant_id
  object_id = data.azurerm_client_config.client_config.object_id

  tags       = var.tags
  depends_on = [module.acr]
}

module "db" {
  source = "./modules/database"

  sql_server_name = var.sql_server_name
  sql_db_name = var.sql_db_name
  kv_id = module.kv.kv_id
  sql_sku = var.sql_sku

  rg_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location

  secret_sql_username_name = var.secret_sql_username_name
  secret_sql_password_name = var.secret_sql_password_name

  tags = var.tags 
}

module "acr" {
  source = "./modules/acr"

  rg_name       = azurerm_resource_group.rg.name
  location      = azurerm_resource_group.rg.location
  acr_name      = local.acr_name
  acr_task_name = var.acr_task_name
  acr_sku       = var.acr_sku
  platform_os   = var.platform_os

  dockerfile_path           = var.dockerfile_path
  docker_build_context_path = module.storage.blob_url
  context_access_token      = module.storage.sas
  docker_image_name         = local.docker_image_name

  tags = local.tags

  depends_on = [module.storage]
}

module "webapp" {
  source = "./modules/webapp"

  service_plan_name = var.service_plan_name
  rg_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  sku_name = var.webapp_sku_name
  webapp_name = var.webapp_name

  docker_image_name = var.docker_image_name
  docker_registry_url = module.acr.acr_login_server
  docker_registry_username = module.acr.admin_username
  docker_registry_password = module.acr.admin_password
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

  tags       = local.tags
  depends_on = [module.aci-redis, module.acr, module.kv, module.aca]
}

provider "kubectl" {
  host                   = yamldecode(module.aks.aks_kube_config).clusters[0].cluster.server
  client_certificate     = base64decode(yamldecode(module.aks.aks_kube_config).users[0].user.client-certificate-data)
  client_key             = base64decode(yamldecode(module.aks.aks_kube_config).users[0].user.client-key-data)
  cluster_ca_certificate = base64decode(yamldecode(module.aks.aks_kube_config).clusters[0].cluster.certificate-authority-data)
  load_config_file       = false
}

provider "kubernetes" {
  host                   = yamldecode(module.aks.aks_kube_config).clusters[0].cluster.server
  client_certificate     = base64decode(yamldecode(module.aks.aks_kube_config).users[0].user.client-certificate-data)
  client_key             = base64decode(yamldecode(module.aks.aks_kube_config).users[0].user.client-key-data)
  cluster_ca_certificate = base64decode(yamldecode(module.aks.aks_kube_config).clusters[0].cluster.certificate-authority-data)
}

module "k8s" {
  source = "./modules/k8s"

  acr_login_server           = module.acr.login_server
  docker_image_name          = local.docker_image_name
  kv_name                    = local.keyvault_name
  secret_sql_username_name = local.secret_sql_username_name
  secret_sql_password_name = local.secret_sql_password_name
  aks_kv_access_identity_id  = module.aks.aks_kv_access_identity_id

  depends_on = [module.aks]
}

