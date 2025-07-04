variable "location" {
  type        = string
  description = "Azure region where resources will be deployed"
}

variable "rg_name" {
  type        = string
  description = "Name of the resource group"
}

variable "sql_server_name" {
  type        = string
  description = "Name of the Azure SQL Server instance"
}

variable "mssql_firewall_rule_name" {
  type = string
}

variable "sql_db_name" {
  type        = string
  description = "Name of the SQL Database"
}

variable "sql_sku" {
  type        = string
  description = "The SKU for the SQL database (e.g., Basic, S0)"
}


variable "secret_sql_username_name" {
  type        = string
  description = "Name of the Key Vault secret to store SQL admin username"
}

variable "secret_sql_password_name" {
  type        = string
  description = "Name of the Key Vault secret to store SQL admin password"
}
variable "kv_id" {
  type = string
}
variable "secret_sql_database_name" {
  type = string
}

variable "secret_sql_connection_string_name" {
  type = string
}

variable "secret_sql_server_fqdn_name" {
  type = string
}