output "vault_cluster" {
  value = formatlist(
    "%s: %s",
    aws_instance.vault_cluster[*].tags.Name,
    aws_instance.vault_cluster[*].public_ip
  )
}

output "vault_replication" {
  value = formatlist(
    "%s: %s",
    aws_instance.vault_replication[*].tags.Name,
    aws_instance.vault_replication[*].public_ip
  )
}
