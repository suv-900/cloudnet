variable "location" {
  type        = string
  description = "location"
}
variable "name_prefix" {
  type        = string
  description = "sku"
}

#acr
variable "acr_sku" {
  type        = string
  description = "sku"
}
variable "dockerfile_path" {
  type        = string
  description = "sku"
}
variable "platform_os" {
  type        = string
  description = "sku"
}
variable "acr_task_name" {
  type        = string
  description = "sku"
}

#kv
variable "kv_sku" {
  description = "sku"
  type        = string
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

#db
variable "sql_server_name" {
  type        = string
  description = "Name of the Azure SQL Server instance"
}

variable "sql_db_name" {
  type        = string
  description = "Name of the SQL Database"
}

variable "sql_sku" {
  type        = string
  description = "The SKU for the SQL database (e.g., Basic, S0)"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
}

variable "secret_sql_username_name" {
  type        = string
  description = "Name of the Key Vault secret to store SQL admin username"
}

variable "secret_sql_password_name" {
  type        = string
  description = "Name of the Key Vault secret to store SQL admin password"
}

#webapp
variable "service_plan_name" {
    type = string
}

variable "rg_name" {
    type = string
}

variable "location" {
    type = string
}

variable "webapp_sku_name" {
  
}

variable "webapp_name" {
    type = string
}

variable "docker_image_name" {
    type = string
}

variable "docker_registry_url" {
    type = string
}

variable "docker_registry_username" {
    type = string
}

variable "docker_registry_password" {
    type = string
}