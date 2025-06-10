resource "azurerm_service_plan" "sap" {
    name = var.service_plan_name
    resource_group_name = var.rg_name
    location = var.location
    os_type = "Linux"
    sku_name = var.sku_name 
}

resource "azurerm_linux_web_app" "webapp" {
    name = var.webapp_name
    resource_group_name = var.rg_name
    location = var.location
    service_plan_id = azurerm_service_plan.sap.id

    app_settings = {
        USER = ""
    }
    site_config {
        application_stack {
            docker_image_name = var.docker_image_name
            docker_registry_url = var.docker_registry_url
            docker_registry_username = var.docker_registry_username
            docker_registry_password = var.docker_registry_password
        }
    }
}