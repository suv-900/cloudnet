resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.rg_name
  location            = var.location
  sku                 = var.acr_sku
  anonymous_pull_enabled = true
  tags                = var.tags
}

resource "azurerm_container_registry_task" "acr_task" {
  name                  = var.acr_task_name
  container_registry_id = azurerm_container_registry.acr.id

  platform {
    os = var.platform_os
  }

  docker_step {
    dockerfile_path      = var.dockerfile_path
    context_path         = var.docker_build_context_path
    context_access_token = var.context_access_token
    image_names          = [var.docker_image_name]
  }
}

resource "azurerm_container_registry_task_schedule_run_now" "acr_task_now" {
  container_registry_task_id = azurerm_container_registry_task.acr_task.id
}