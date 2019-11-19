data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "backup" {
  name     = "rg-${var.name}"
  location = var.location

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "random_id" "storageaccount" {
  keepers = {
    rg_name     = azurerm_resource_group.backup.name
    rg_location = azurerm_resource_group.backup.location
  }
  byte_length = 11
}

resource "azurerm_storage_account" "backup" {
  name                     = "sa${random_id.storageaccount.hex}"
  resource_group_name      = azurerm_resource_group.backup.name
  location                 = azurerm_resource_group.backup.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_storage_container" "velero" {
  name                  = var.bucket
  storage_account_name  = azurerm_storage_account.backup.name
  container_access_type = "private"

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      tags,
    ]
  }
}
