resource "kubectl_manifest" "secret_provider" {
  yaml_body = templatefile("${path.root}/k8s-manifests/secret-provider.yaml.tftpl", {
    aks_kv_access_identity_id  = var.aks_kv_access_identity_id
    kv_name                    = var.kv_name
    redis_url_secret_name      = var.redis_hostname_secret_name
    redis_password_secret_name = var.redis_password_secret_name
    tenant_id                  = var.tenant_id
  })
}

resource "kubectl_manifest" "deployment" {
  yaml_body = templatefile("${path.root}/k8s-manifests/deployment.yaml.tftpl", {
    acr_login_server = var.acr_login_server
    app_image_name   = var.docker_image_name
    image_tag        = "latest"
    sql_database_url = var.sql_database_url
    sql_server_url = var.sql_server_url
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