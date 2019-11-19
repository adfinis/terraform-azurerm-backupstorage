# Terraform Azure backup storage

This module creates the Azure Blob Storage infrastructure needed to backup an
AKS cluster using [Velero](https://velero.io).

This module only automates creating the needed infrastructure and it does not
deploy a cluster or Velero inside the cluster.

## Prerequisites

For this module to make sense you need to have deployed an Azure Kubernetes
Service that where you would like to run Velero.

## Overview

This module creates the following resources.

* azurerm_resource_group.backup
* azurerm_storage_account.backup
* azurerm_storage_container.velero

It supports the following variables.

* location (Required)
* name
* account_tier
* account_replication_type
* bucket

It outputs the following information.

 * backup_subscription_id
 * backup_tenant_id
 * backup_client_id
 * backup_client_secret
 * backup_resource_group
 * backup_storage_account_name

## Usage

```hcl
module "backup" {
  source  = "adfinis-sygroup/backupstorage/azurerm"
  version = "0.0.0"
}
```

Grab the output from terraform and use it to create a Kubernetes secret for
Velero.

```bash
backupNamespace="velero"
backupCloudCredentials="velero-azure-credentials"

# grab needed information from AKS deployment (outside of this modules scope)
aksName="aks-..."
aksResourceGroup="rg-..."
aksMcResourceGroup=`az aks show \
  --resource-group "${aksResourceGroup}" \
  --name "${aksName}" -ojson | jq -r '.nodeResourceGroup'`

# grab information from terraform output
subscriptionId=`terraform output -json \
  | jq -r '.backup_subscription_id | .value' \
  | sed 's@/subscriptions/@@'`
tenantId=`terraform output -json | jq -r '.backup_tenant_id | .value'`
clientId=`terraform output -json | jq -r '.backup_client_id | .value'`
clientSecret=`terraform output -json | jq -r '.backup_client_secret | .value'`


# create namspace and secret
kubectl create namespace "${backupNamespace}"

kubectl create secret generic "${backupCloudCredentials}" \
  --namespace "${backupNamespace}" \
  --from-literal="AZURE_SUBSCRIPTION_ID=${subscriptionId}" \
  --from-literal="AZURE_TENANT_ID=${tenantId}" \
  --from-literal="AZURE_CLIENT_ID=${clientId}" \
  --from-literal="AZURE_CLIENT_SECRET=${clientSecret}" \
  --from-literal="AZURE_RESOURCE_GROUP=${aksMcResourceGroup}" \
  --from-literal="AZURE_CLOUD_NAME=AzurePublicCloud"
```

Create a `values.yaml` to use with helm install stable/velero (also outside of
the scope of this module.

```bash
backupResourceGroup=`terraform output -json \
  | jq -r '.backup_resource_group | .value'`
backupStorageAccountName=`terraform output -json \
  | jq -r '.backup_storage_account_name | .value'`

cat > velero.values.yaml <<EOYAML
configuration:
  provider: azure
  backupStorageLocation:
    name: azure
    bucket: velero
    config:
      resourceGroup: ${backupResourceGroup}
      storageAccount: ${backupStorageAccountName}
  volumeSnapshotLocation:
    name: azure
    config:
      resourceGroup: ${backupResourceGroup}
EOYAML
```

## License
This module is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, version 3 of the License.

## Copyright

Copyright (c) 2019 [Adfinis SyGroup AG](https://adfinis-sygroup.ch/)
