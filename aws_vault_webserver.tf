# resource "aws_instance" "vault_webserver" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = var.aws_instance_type
#   key_name      = aws_key_pair.key.key_name
#   tags = {
#     Name = "vault-fundamentals-webserver-01",
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo hostnamectl set-hostname ${self.tags.Name}",
#       "sudo apt update && sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql"
#     ]

#     connection {
#       type        = "ssh"
#       host        = self.public_ip
#       user        = "ubuntu"
#       private_key = file(var.ssh_private_key_location)
#     }
#   }
# }

# output "vault_webserver" {
#   value = formatlist(
#     "%s => %s",
#     aws_instance.vault_webserver.tags.Name,
#     aws_instance.vault_webserver.public_ip
#   )
# }
