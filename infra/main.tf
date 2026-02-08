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

resource "azurerm_log_analytics_workspace" "law" {
  name                = "${local.prefix_clean}-law"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_container_registry" "acr" {
  name                = substr("${local.prefix_clean}acr${random_string.suffix.result}", 0, 24)
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
  tags                = var.tags
}

resource "azurerm_container_app_environment" "env" {
  name                       = "${local.prefix_clean}-env"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  tags                       = var.tags
}

resource "azurerm_container_app_environment_storage" "presets" {
  name                         = "presets"
  container_app_environment_id = azurerm_container_app_environment.env.id
  account_name                 = azurerm_storage_account.sa.name
  share_name                   = azurerm_storage_share.presets.name
  access_key                   = azurerm_storage_account.sa.primary_access_key
  access_mode                  = "ReadOnly"
}

resource "azurerm_container_app_environment_storage" "sessions" {
  name                         = "sessions"
  container_app_environment_id = azurerm_container_app_environment.env.id
  account_name                 = azurerm_storage_account.sa.name
  share_name                   = azurerm_storage_share.sessions.name
  access_key                   = azurerm_storage_account.sa.primary_access_key
  access_mode                  = "ReadWrite"
}

resource "azurerm_container_app_environment_storage" "prompts" {
  name                         = "prompts"
  container_app_environment_id = azurerm_container_app_environment.env.id
  account_name                 = azurerm_storage_account.sa.name
  share_name                   = azurerm_storage_share.prompts.name
  access_key                   = azurerm_storage_account.sa.primary_access_key
  access_mode                  = "ReadOnly"
}

resource "azurerm_container_app" "app" {
  name                         = "${local.prefix_clean}-api"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"
  tags                         = var.tags

  registry {
    server               = azurerm_container_registry.acr.login_server
    username             = azurerm_container_registry.acr.admin_username
    password_secret_name = "acr-password"
  }

  secret {
    name  = "acr-password"
    value = azurerm_container_registry.acr.admin_password
  }

  ingress {
    external_enabled = true
    target_port      = 8000
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    container {
      name   = "api"
      image  = var.container_image
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "IMG_ROOT"
        value = "/data/presets"
      }
      env {
        name  = "SESSIONS_ROOT"
        value = "/data/sessions"
      }
      env {
        name  = "PROMPTS_XLSX"
        value = "/data/prompts/HairstylePresertPromts.xlsx"
      }
      env {
        name  = "LIGHTX_API_KEY"
        value = var.lightx_api_key
      }

      volume_mounts {
        name = "presets"
        path = "/data/presets"
      }
      volume_mounts {
        name = "sessions"
        path = "/data/sessions"
      }
      volume_mounts {
        name = "prompts"
        path = "/data/prompts"
      }
    }

    volume {
      name         = "presets"
      storage_name = azurerm_container_app_environment_storage.presets.name
      storage_type = "AzureFile"
    }
    volume {
      name         = "sessions"
      storage_name = azurerm_container_app_environment_storage.sessions.name
      storage_type = "AzureFile"
    }
    volume {
      name         = "prompts"
      storage_name = azurerm_container_app_environment_storage.prompts.name
      storage_type = "AzureFile"
    }
  }
}
