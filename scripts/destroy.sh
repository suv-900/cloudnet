rg_name="suvham-tfstate-rg"
rg_location="southindia"
storage_account_name="suvhamtfstatesa"
storage_account_sku="Standard_LRS"
storage_container_name="suvham-tfstate-container"

az storage container delete --name $storage_container_name --account-name $storage_account_name

az storage account delete --name $storage_account_name --resource-group $rg_name --yes

az group delete --name $rg_name --yes