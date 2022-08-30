# Vault Fundamentals

This repository is to deploy a demo environment for the Vault Fundamentals training / workshop.  
The following resources will be deployed in AWS:

- 1 SSH key-pair
- 1 KMS key for auto-unseal
- 3 EC2 instances for an HA vault cluster
- 2 EC2 instances for replication purposes
- 1 EC2 instance for a webserver (currently disabled)

Please note that

- All Vault instances will be provisioned with Vault Enterprise, including a config file, NFR license and a .env file containing AWS credentials.
- All Vault instances will be in an uninitialized and sealed state.
- All Vault services will not be started at system startup.
- The 3-node Vault cluster will be provisioned with tags to leverage the auto_join capabilities and is included in the config file.

## Pre-requisites

Please copy the following files to user-defined ones and fill in the blanks.

```bash
for i in *.example; do cp -a $i ${i%%.example}; done
```

## Deploy infrastructure

```bash
terraform init && terraform apply
```

After that you will be presented with a list of names and IP addresses of the provisioned instances.


## Demo guidelines

Here are some code snippets that will help you guide the demo environment for the following purposes

### HA

1. On `vault-fundamentals-node-1`, perform the following:

   ```bash
   sudo service vault start && vault operator init -recovery-shares=1 -recovery-threshold=1 | tee vault.creds | awk '/Initial Root Token:/ { print $4 }' | vault login -
   echo "Recovery Key for nodes 2 and 3 is: " `awk '/Recovery Key 1/ { print $4 }' vault.creds`
   ```

2. On `vault-fundamentals-node-2` and `vault-fundamentals-node-3`, perform the following

   ```bash
   sudo service vault start
   vault operator unseal
    ```

3. On `vault-fundamentals-node-1`, perform the following:

  ```bash
  vault operator raft list-peers
  vault operator step-down
  vault operator raft list-peers
  ```

### Replication

#### Performance replication

1. On `vault-fundamentals-node-1`, perform the following:

  ```bash
  vault read sys/replication/performance/status
  vault write -f sys/replication/performance/primary/enable
  vault read sys/replication/performance/status
  vault write -f sys/replication/performance/primary/secondary-token id=performance-node
  ```

2. On `vault-fundamentals-replication-1`, perform the following:

  ```bash
  sudo service vault start && vault operator init -recovery-shares=1 -recovery-threshold=1 | tee vault.creds | awk '/Initial Root Token:/ { print $4 }' | vault login -
  vault read sys/replication/performance/status
  vault write -f sys/replication/performance/secondary/enable token=<token from `vault-fundamentals-node-1`>
  vault read sys/replication/performance/status
  ```

#### Disaster recovery

1. On `vault-fundamentals-node-1`, perform the following:

  ```bash
  vault read sys/replication/dr/status
  vault write -f sys/replication/dr/primary/enable
  vault read sys/replication/dr/status
  vault write -f sys/replication/dr/primary/secondary-token id=dr-node
  ```

2. On `vault-fundamentals-replication-2`, perform the following:

  ```bash
  sudo service vault start && vault operator init -recovery-shares=1 -recovery-threshold=1 | tee vault.creds | awk '/Initial Root Token:/ { print $4 }' | vault login -
  vault read sys/replication/dr/status
  vault write -f sys/replication/dr/secondary/enable token=<token from `vault-fundamentals-node-1`>
  vault read sys/replication/dr/status
  ```

## Destroy infrastructure

```bash
terraform destroy
```

Note that when you destroy the environment, the KMS key will not be deleted immediately, but it will be scheduled for deletion in the next 7 days.
