variable "service_plan_name" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sku_name" {

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

variable "secure_envvars" {
  type = map(string)
  sensitive = true
}