output "backup_subscription_id" {
  value = data.azurerm_subscription.current.id
}

output "backup_tenant_id" {
  value = data.azurerm_subscription.current.tenant_id
}

output "backup_client_id" {
  value = azurerm_storage_account.backup.identity.0.principal_id
}

output "backup_client_secret" {
  value = azurerm_storage_account.backup.primary_access_key
}

output "backup_resource_group" {
  value = azurerm_resource_group.backup.name
}

output "backup_storage_account_name" {
  value = "sa${random_id.storageaccount.hex}"
}

