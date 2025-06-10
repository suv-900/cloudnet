variable "location" {
  type        = string
  description = "location"
}
variable "name_prefix" {
  type        = string
  description = "sku"
}

variable "rg_name" {
  type = string
}

#acr
variable "acr_sku" {
  type        = string
  description = "sku"
}
variable "acr_name" {
  type = string
}
#kv
variable "kv_sku" {
  description = "sku"
  type        = string
}
variable "keyvault_name" {
  type = string
}


#aks
variable "system_node_pool_name" {
  type        = string
  description = "sku"
}
variable "system_node_pool_node_count" {
  type        = number
  description = "sku"
}
variable "system_node_pool_vm_size" {
  type        = string
  description = "sku"
}
variable "aks_name" {
  type = string
}

#db
variable "sql_server_name" {
  type = string
}
variable "sql_db_name" {
  type = string
}
variable "sql_sku" {
  type = string
}
variable "secret_sql_username_name" {
  type = string
}
variable "secret_sql_password_name" {
  type = string
}

#webapp
variable "service_plan_name" {
  type = string
}
variable "webapp_name" {
  type = string
}
variable "service_plan_sku" {
  type = string
}

variable "dns_prefix" {
  type = string
}