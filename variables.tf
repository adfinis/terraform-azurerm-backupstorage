variable "location" {
  description = "Location where the backup storage will be created."
  type        = string
}

variable "name" {
  description = "Name of the resource group where the storage will be created, gets prefixed with 'rg-'."
  type        = string
  default     = "velero"
}

variable "account_tier" {
  description = "Account tier of the storage account that will be created."
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "replication type of the storage account that will be created."
  type        = string
  default     = "LRS"
}

variable "bucket" {
  description = "Bucket that will be created for Velero."
  type        = string
  default     = "velero"
}
