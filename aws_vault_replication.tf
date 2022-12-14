resource "aws_instance" "vault_replication" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.aws_instance_type
  key_name               = aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.vault_sg.id]
  count                  = var.aws_instance_replication_count
  tags = {
    Name = "vrepl${format("%02d", count.index + 1)}",
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
      var.vault_replication_config_file_source,
      {
        node_ip           = self.public_ip,
        raft_node_id      = self.tags.Name,
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
      "sudo apt update && sudo apt install -y gpg jq",
      "wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null",
      "echo \"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main\" | sudo tee /etc/apt/sources.list.d/hashicorp.list",
      "sudo apt update && sudo apt install -y ${var.vault_binary_name}",
      "sudo mv ${var.vault_enterprise_license_destination} /etc/vault.d/vault.hclic",
      "sudo mv ${var.vault_env_file_destination} /etc/vault.d/vault.env",
      "sudo mv ${var.vault_config_file_destination} /etc/vault.d/vault.hcl",
      "sudo chown vault:vault /etc/vault.d/vault.env",
      "sudo chown vault:vault /etc/vault.d/vault.hclic",
      "sudo chmod 600 /etc/vault.d/vault.env",
      "sudo chmod 600 /etc/vault.d/vault.hclic",
      "echo \"export VAULT_ADDR=http://127.0.0.1:8200\" | sudo tee /etc/profile.d/vault.sh",
      "touch /home/ubuntu/.hushlogin"
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_location)
    }
  }
}

output "vault_replication" {
  value = formatlist(
    "%s => %s",
    aws_instance.vault_replication[*].tags.Name,
    aws_instance.vault_replication[*].public_dns
  )
}
