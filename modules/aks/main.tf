resource "azurerm_kubernetes_cluster" "k8_cluster" {
  name                   = var.aks_cluster_name
  resource_group_name    = var.rg_name
  location               = var.location
  dns_prefix             = "${var.dns_prefix}-dns"
  local_account_disabled = false

  default_node_pool {
    name            = var.system_node_pool_name
    node_count      = var.system_node_pool_node_count
    vm_size         = var.system_node_pool_vm_size
    os_disk_type    = "Ephemeral"
    os_disk_size_gb = 30

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  identity {
    type = "SystemAssigned"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "role_assignment" {
  role_definition_name = "AcrPull"
  scope                = var.acr_id
  principal_id         = azurerm_kubernetes_cluster.k8_cluster.kubelet_identity[0].object_id

  depends_on = [azurerm_kubernetes_cluster.k8_cluster]
}

resource "azurerm_key_vault_access_policy" "access_policy1" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = azurerm_kubernetes_cluster.k8_cluster.key_vault_secrets_provider[0].secret_identity[0].object_id

  secret_permissions = ["Get", "List"]

  depends_on = [azurerm_role_assignment.role_assignment]
}

resource "azurerm_key_vault_access_policy" "access_policy2" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = azurerm_kubernetes_cluster.k8_cluster.kubelet_identity[0].object_id

  secret_permissions = ["Get", "List"]

  depends_on = [azurerm_key_vault_access_policy.access_policy1]
}

data "azurerm_client_config" "client_config" {}

resource "kubectl_manifest" "secret_provider" {
  yaml_body = templatefile("${path.root}/k8s-manifests/secret-provider.yaml.tftpl", {
    aks_kv_access_identity_id  = var.aks_kv_access_identity_id
    kv_name                    = var.kv_name
    redis_url_secret_name      = var.redis_hostname_secret_name
    redis_password_secret_name = var.redis_password_secret_name
    tenant_id                  = data.azurerm_client_config.client_config.tenant_id
  })
}

resource "kubectl_manifest" "deployment" {
  yaml_body = templatefile("${path.root}/k8s-manifests/deployment.yaml.tftpl", {
    acr_login_server = var.acr_login_server
    app_image_name   = var.docker_image_name
    image_tag        = "latest"
  })

  wait_for {
    field {
      key   = "status.availableReplicas"
      value = "1"
    }
  }
  depends_on = [kubectl_manifest.secret_provider]
}

resource "kubectl_manifest" "service" {
  wait_for {
    field {
      key        = "status.loadBalancer.ingress.[0].ip"
      value      = "^(\\d+(\\.|$)){4}"
      value_type = "regex"
    }
  }

  yaml_body = file("${path.root}/k8s-manifests/service.yaml")

  depends_on = [kubectl_manifest.deployment]
}

data "kubernetes_service" "k8_service" {
  metadata {
    name = "redis-flask-app-service"
  }
  depends_on = [kubectl_manifest.service]
}