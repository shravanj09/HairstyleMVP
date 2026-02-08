output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "web_app_name" {
  value = azurerm_linux_web_app.app.name
}

output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}

output "presets_share_name" {
  value = azurerm_storage_share.presets.name
}

output "sessions_share_name" {
  value = azurerm_storage_share.sessions.name
}

output "prompts_share_name" {
  value = azurerm_storage_share.prompts.name
}
