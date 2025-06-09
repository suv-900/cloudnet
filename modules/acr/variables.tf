variable "acr_name" {
  type        = string
  description = "acr name"
}
variable "rg_name" {
  type        = string
  description = "rg name"
}

variable "location" {
  type        = string
  description = "location"
}

variable "acr_sku" {
  type        = string
  description = "sku"
}
variable "dockerfile_path" {
  type        = string
  description = "sku"
}
variable "docker_build_context_path" {
  type        = string
  description = "sku"
}
variable "context_access_token" {
  type        = string
  description = "sku"
}

variable "platform_os" {
  description = "sku"
  type        = string
}

variable "acr_task_name" {
  description = "sku"
  type        = string
}
variable "docker_image_name" {
  type        = string
  description = "sku"
}
variable "tags" {
  type        = map(string)
  description = "sku"
}