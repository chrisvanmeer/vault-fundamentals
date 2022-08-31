resource "local_file" "tmux" {
  content = templatefile("vault-tmux.tftpl",
    {
      vnode01 = aws_instance.vault_cluster[0].public_dns,
      vnode02 = aws_instance.vault_cluster[1].public_dns,
      vnode03 = aws_instance.vault_cluster[2].public_dns,
      vrepl01 = aws_instance.vault_replication[0].public_dns,
      vrepl02 = aws_instance.vault_replication[1].public_dns
      vrepl03 = aws_instance.vault_replication[2].public_dns
    }
  )
  filename = "./vault-tmux.sh"
}
