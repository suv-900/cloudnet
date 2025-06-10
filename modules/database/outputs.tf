output "server_url" {
    value = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}
output "db_url" {
  description = "SQL Connection String for ADO.NET clients"
  value = format(
    "Server=tcp:%s,1433;Initial Catalog=%s;Persist Security Info=False;User ID=%s;Password=%s;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;",
    azurerm_mssql_server.sql.fully_qualified_domain_name,
    azurerm_mssql_database.sql_db.name,
    random_pet.sql_username,
    random_password.sql_password.result
  )
  sensitive = true
}