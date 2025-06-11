variable "location" {
  type        = string
  description = "location"
}

variable "environment" {
  type = string
}

#acr
variable "acr_sku" {
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
variable "sql_sku" {
  type = string
}

#webapp
variable "service_plan_sku" {
  type = string
}
variable "node_version" {
  type = string
}