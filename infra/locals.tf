locals {
  rg_name       = format("%s-suvham-rg", var.environment)
  keyvault_name = format("%s-suvham-kv", var.environment)

  sql_server_name = format("%s-suvham-sqlserver", var.environment)
  sql_db_name     = format("%s-sql-db", var.environment)

  acr_name = format("%ssuvhamacr", var.environment)

  asp_name = format("%s-suvham-asp", var.environment)
  app_name = format("%s-suvham-webapp", var.environment)

  aks_name = format("%s-suvham-aks", var.environment)

  secret_sql_username_name          = format("%s-sql-user", var.environment)
  secret_sql_password_name          = format("%s-sql-password", var.environment)
  secret_sql_connection_string_name = format("%s-sql-connection-string", var.environment)
  secret_sql_server_fqdn_name       = format("%s-sql-server-fqdn", var.environment)
  secret_sql_database_name          = format("%s-sql-database-name", var.environment)
  mssql_firewall_rule_name          = format("%s-sql-firewall1", var.environment)

  dns_prefix = format("%s-suvham-dns", var.environment)
}