locals {
  prefix_clean = lower(replace(var.name_prefix, "/[^a-z0-9]/", ""))
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.prefix_clean}-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "sa" {
  name                     = substr("${local.prefix_clean}${random_string.suffix.result}", 0, 24)
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
}

resource "azurerm_storage_share" "presets" {
  name                 = "presets"
  storage_account_name = azurerm_storage_account.sa.name
  quota                = 50
}

resource "azurerm_storage_share" "sessions" {
  name                 = "sessions"
  storage_account_name = azurerm_storage_account.sa.name
  quota                = 50
}

resource "azurerm_storage_share" "prompts" {
  name                 = "prompts"
  storage_account_name = azurerm_storage_account.sa.name
  quota                = 5
}

resource "azurerm_service_plan" "plan" {
  name                = "${local.prefix_clean}-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku
  tags                = var.tags
}

resource "azurerm_linux_web_app" "app" {
  name                = "${local.prefix_clean}-api-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id
  https_only          = true
  tags                = var.tags

  site_config {
    always_on       = false
    http2_enabled   = true
    ftps_state      = "Disabled"
    app_command_line = "python -m uvicorn local_app.app:app --host 0.0.0.0 --port 8000"

    application_stack {
      python_version = var.python_version
    }
  }

  app_settings = {
    WEBSITES_PORT       = "8000"
    IMG_ROOT            = "/data/presets"
    SESSIONS_ROOT       = "/data/sessions"
    PROMPTS_XLSX        = "/data/prompts/HairstylePresertPromts.xlsx"
    LIGHTX_API_KEY      = var.lightx_api_key
    SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
  }

  storage_account {
    name         = "presets"
    type         = "AzureFiles"
    account_name = azurerm_storage_account.sa.name
    share_name   = azurerm_storage_share.presets.name
    access_key   = azurerm_storage_account.sa.primary_access_key
    mount_path   = "/data/presets"
  }

  storage_account {
    name         = "sessions"
    type         = "AzureFiles"
    account_name = azurerm_storage_account.sa.name
    share_name   = azurerm_storage_share.sessions.name
    access_key   = azurerm_storage_account.sa.primary_access_key
    mount_path   = "/data/sessions"
  }

  storage_account {
    name         = "prompts"
    type         = "AzureFiles"
    account_name = azurerm_storage_account.sa.name
    share_name   = azurerm_storage_share.prompts.name
    access_key   = azurerm_storage_account.sa.primary_access_key
    mount_path   = "/data/prompts"
  }
}
