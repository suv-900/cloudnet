location = "southindia"
rg_name  = "suvham-rg-1"

name_prefix = "suvham-123123"

#acr
acr_sku  = "Basic"
acr_name = "suvhamacr1"
#kv
kv_sku        = "standard"
keyvault_name = "suvham-kv-1"

#aks
system_node_pool_name       = "system"
system_node_pool_node_count = 1
system_node_pool_vm_size    = "Standard_D2ads_v5"
aks_name                    = "suvham-aks-1"

#db
sql_db_name     = "suvham-sql-db-1"
sql_server_name = "suvham-sql-server-1"
sql_sku         = "S2"
secret_sql_username_name = "sql-username"
secret_sql_password_name = "sql-password"

#webapp
service_plan_name = "suvham-service-plan-1"
service_plan_sku  = "P0v3"
webapp_name = "suvham-webapp1"

dns_prefix = "suvham-dns-1"