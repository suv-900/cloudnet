resource "azurerm_service_plan" "sap" {
  name                = var.service_plan_name
  resource_group_name = var.rg_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.service_plan_sku
}

resource "azurerm_linux_web_app" "webapp" {
  name                = var.webapp_name
  resource_group_name = var.rg_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.sap.id

  app_settings = var.secure_envvars
  site_config {
    application_stack {
      node_version = var.node_version
    }
  }
}