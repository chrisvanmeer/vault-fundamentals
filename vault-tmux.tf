resource "local_file" "tmux" {
  content = templatefile("vault-tmux.tftpl",
    {
      node01 = aws_instance.vault_cluster[0].public_dns
      node02 = aws_instance.vault_cluster[1].public_dns
      node03 = aws_instance.vault_cluster[2].public_dns
      repl01 = aws_instance.vault_replication[0].public_dns
      repl02 = aws_instance.vault_replication[1].public_dns
    }
  )
  filename = "./vault-tmux.sh"
}
