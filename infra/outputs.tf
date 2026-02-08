output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "container_app_name" {
  value = azurerm_container_app.app.name
}

output "container_app_fqdn" {
  value = azurerm_container_app.app.ingress[0].fqdn
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

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "acr_username" {
  value = azurerm_container_registry.acr.admin_username
}

output "acr_password" {
  value     = azurerm_container_registry.acr.admin_password
  sensitive = true
}
