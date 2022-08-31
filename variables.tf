variable "ssh_public_key_location" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key_location" {
  type    = string
  default = "~/.ssh/id_rsa"
}

variable "aws_key_pair_key_name" {
  type    = string
  default = "vault-fundamentals-demo-key"
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "aws_account_id" {
  type = string
}

variable "aws_iam_user" {
  type = string
}

variable "aws_instance_cluster_count" {
  type    = number
  default = 3
}

variable "aws_instance_replication_count" {
  type    = number
  default = 3
}

variable "aws_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "vault_binary_name" {
  type    = string
  default = "vault-enterprise"
}

variable "vault_enterprise_license_source" {
  type    = string
  default = "vault.hclic"
}

variable "vault_enterprise_license_destination" {
  type    = string
  default = "/home/ubuntu/vault.hclic"
}

variable "vault_env_file_source" {
  type    = string
  default = "vault.env"
}

variable "vault_env_file_destination" {
  type    = string
  default = "/home/ubuntu/vault.env"
}

variable "vault_cluster_config_file_source" {
  type    = string
  default = "vault.hcl.tftpl"
}

variable "vault_replication_config_file_source" {
  type    = string
  default = "vault.hcl.replication.tftpl"
}

variable "vault_config_file_destination" {
  type    = string
  default = "/home/ubuntu/vault.hcl"
}

variable "vault_aws_unseal_tag_key" {
  type    = string
  default = "vault-auto-unseal"
}

variable "vault_aws_unseal_tag_value" {
  type    = string
  default = "true"
}
