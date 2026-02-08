# Infra (Option A: App Service + Azure Files)

## Prereqs
- Terraform 1.5+
- Azure CLI
- Service principal with Contributor on the subscription

## 1) Set env for Terraform
```
$env:ARM_SUBSCRIPTION_ID="871a121e-efac-48a6-b0b0-f0b1b7be66c2"
$env:ARM_TENANT_ID="76f541ef-f9f9-4810-888a-5bfc7fabeb97"
$env:ARM_CLIENT_ID="<appId>"
$env:ARM_CLIENT_SECRET="<password>"
```

## 2) (Recommended) Terraform Remote State (Azure Storage)
Create a storage account + container for state **once**:
```
az group create -n hairstylelooksmvp-tfstate-rg -l eastus
az storage account create -n hairstylelooksmvpstate -g hairstylelooksmvp-tfstate-rg -l eastus --sku Standard_LRS
az storage container create --name tfstate --account-name hairstylelooksmvpstate
```

Then init with backend config:
```
terraform init ^
  -backend-config="resource_group_name=hairstylelooksmvp-tfstate-rg" ^
  -backend-config="storage_account_name=hairstylelooksmvpstate" ^
  -backend-config="container_name=tfstate" ^
  -backend-config="key=hairstylemvp.tfstate"
```

## 3) Init + Apply
```
terraform init
terraform apply -var="name_prefix=hairstylelooksmvp" -var="lightx_api_key=YOUR_KEY"
```

## 4) Upload presets/prompts to Azure Files
Use scripts in `scripts/` after apply to upload:
- `img/` → `presets` share
- `HairstylePresertPromts.xlsx` → `prompts` share

## 5) Deploy app
Use GitHub Actions workflow or zip deploy:
```
az webapp deploy --resource-group <rg> --name <app> --src-path . --type zip
```
