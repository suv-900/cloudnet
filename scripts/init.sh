rg_name="suvham-tfstate-rg"
rg_location="southindia"
storage_account_name="suvhamtfstatesa"
storage_account_sku="Standard_LRS"
storage_container_name="suvham-tfstate-container"

az group create --name $rg_name --location $rg_location

az storage account create --name $storage_account_name --resource-group $rg_name --sku $storage_account_sku

az storage container create --name $storage_container_name --account-name $storage_account_name 