rg_name="suvham-tfstate-rg456"
rg_location="southindia"
storage_account_name="suvham-tfstate-sa-456"
storage_account_sku="Standard_LRS"
dev_container_name="dev-tfstate-container-456"
qa_container_name="qa-tfstate-container-456"
stage_container_name="stage-tfstate-container-456"
prod_container_name="prod-tfstate-container-456"

az group create --name $rg_name --location $rg_location

az storage account create --name $storage_account_name --resource-group $rg_name --sku $storage_account_sku

az storage container create --name $dev_container_name --account-name $storage_account_name --public-access blob 
az storage container create --name $qa_container_name --account-name $storage_account_name --public-access blob 
az storage container create --name $stage_container_name --account-name $storage_account_name --public-access blob 
az storage container create --name $prod_container_name --account-name $storage_account_name --public-access blob 