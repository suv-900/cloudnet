variable "service_plan_name" {
  type = string
}
variable "service_plan_sku" {
  type = string
}
variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "webapp_name" {
  type = string
}

variable "secure_envvars" {
  type      = map(string)
  sensitive = true
}

variable "node_version" {
  type = string
}