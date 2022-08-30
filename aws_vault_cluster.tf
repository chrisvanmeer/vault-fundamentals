resource "aws_instance" "vault_cluster" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.aws_instance_type
  key_name      = aws_key_pair.key.key_name
  count         = var.aws_instance_cluster_count
  tags = {
    Name                         = "vault-fundamentals-node-${format("%02d", count.index + 1)}",
    var.vault_aws_unseal_tag_key = var.vault_aws_unseal_tag_value
  }

  provisioner "file" {

    source      = var.vault_enterprise_license_source
    destination = var.vault_enterprise_license_destination

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_location)
    }
  }

  provisioner "file" {

    source      = var.vault_env_file_source
    destination = var.vault_env_file_destination

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_location)
    }
  }

  provisioner "file" {
    content = templatefile(
      var.vault_cluster_config_file_source,
      {
        node_ip           = self.public_ip,
        raft_node_id      = self.tags.Name,
        raft_tag_key      = var.vault_aws_unseal_tag_key,
        raft_tag_value    = var.vault_aws_unseal_tag_value,
        awskms_region     = var.aws_region,
        awskms_kms_key_id = aws_kms_key.autounseal_key.arn
      }
    )
    destination = var.vault_config_file_destination

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_location)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${self.tags.Name}",
      "sudo apt update && sudo apt install gpg",
      "wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null",
      "echo \"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main\" | sudo tee /etc/apt/sources.list.d/hashicorp.list",
      "sudo apt update && sudo apt install -y ${var.vault_binary_name}",
      "sudo mv ${var.vault_enterprise_license_destination} /etc/vault.d/vault.hclic",
      "sudo mv ${var.vault_env_file_destination} /etc/vault.d/vault.env",
      "sudo mv ${var.vault_config_file_destination} /etc/vault.d/vault.hcl",
      "echo \"export VAULT_ADDR=http://127.0.0.1:8200\" >> /home/ubuntu/.bashrc"
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_location)
    }
  }
}

output "vault_cluster" {
  value = formatlist(
    "%s => %s",
    aws_instance.vault_cluster[*].tags.Name,
    aws_instance.vault_cluster[*].public_ip
  )
}
