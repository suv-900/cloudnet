locals {
  rg_name = format("%s-rg", var.name_prefix)

  docker_image_name = format("%s-app", var.name_prefix)

  aks_name = format("%s-aks", var.name_prefix)

  acr_name = lower(replace(format("%scr", var.name_prefix), "-", ""))

  keyvault_name = format("%s-kv", var.name_prefix)

  secret_sql_username_name = "sql_username"
  secret_sql_password_name = "sql-password"

  tags = {
    Creator = "suvham_paul@epam.com"
  }

  dns_name_label = "suvhamdnslabel"
  dns_prefix     = "${var.name_prefix}-k8s"
}