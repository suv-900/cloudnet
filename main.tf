provider "azurerm" {
  features {}
  subscription_id         = "a53670da-bf9b-4c7d-825a-7544c720e890"
  client_id               = "23a31c03-6ef6-4e82-b017-d4d250ad7d32"
  client_secret_file_path = "C:\\Users\\suvham_paul\\Desktop\\learn-terraform\\tasks\\task8b_off\\task08_b\\.client_secret"
  tenant_id               = "b41b72d0-4e9f-4c26-8a69-f949f367c91d"
}

data "azurerm_client_config" "client_config" {}

resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location

  tags = local.tags
}

module "storage" {
  source = "./modules/storage"

  rg_name  = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location

  account_name             = local.sa_name
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type

  container_name        = var.storage_container_name
  container_access_type = var.storage_container_access_type

  blob_name         = var.storage_blob_name
  blob_content_type = var.blob_content_type
  blob_type         = var.blob_type

  archive_type        = var.archive_type
  archive_source_dir  = var.archive_source_dir
  archive_output_path = var.archive_output_path

  tags = local.tags
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


module "kv" {
  source = "./modules/keyvault"

  kv_name  = local.keyvault_name
  rg_name  = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  sku      = var.kv_sku

  tenant_id = data.azurerm_client_config.client_config.tenant_id
  object_id = data.azurerm_client_config.client_config.object_id

  tags       = local.tags
  depends_on = [module.acr]
}

module "aci-redis" {
  source = "./modules/aci_redis"

  container_group_name       = local.redis_aci_name
  rg_name                    = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  os_type                    = var.aci_os_type
  sku                        = var.aci_redis_sku
  key_vault_id               = module.kv.kv_id
  redis_hostname_secret_name = local.redis_hostname_secret_name
  redis_password_secret_name = local.redis_password_secret_name

  container_name   = var.aci_container_name
  container_cpu    = var.aci_container_cpu
  container_image  = var.aci_container_image
  container_memory = var.aci_container_memory

  tags       = local.tags
  depends_on = [module.acr, module.kv]
}

module "aca" {
  source = "./modules/aca"

  ua_name   = var.aca_ua_name
  rg_name   = azurerm_resource_group.rg.name
  location  = azurerm_resource_group.rg.location
  tenant_id = data.azurerm_client_config.client_config.tenant_id

  acr_id     = module.acr.acr_id
  acr_server = module.acr.login_server

  acae_workload_profile_name = var.acae_workload_profile_name
  acae_workload_profile_type = var.acae_workload_profile_type

  container_app_env_name      = local.aca_env_name
  container_app_name          = local.aca_name
  container_app_revision_mode = var.container_app_revision_mode

  container_name   = var.container_name
  container_image  = "${module.acr.login_server}/${local.docker_image_name}:latest"
  container_cpu    = var.container_cpu
  container_memory = var.container_memory

  kv_id                       = module.kv.kv_id
  kv_secret_redis_hostname_id = module.aci-redis.kv_secret_redis_hostname_id
  kv_secret_redis_password_id = module.aci-redis.kv_secret_redis_password_id

  tags       = local.tags
  depends_on = [module.aci-redis, module.acr, module.kv]
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
  redis_hostname_secret_name = var.redis_hostname_secret_name
  redis_password_secret_name = var.redis_password_secret_name
  aks_kv_access_identity_id  = module.aks.aks_kv_access_identity_id

  depends_on = [module.aks]
}

