resource "aws_security_group" "vault_sg" {
  name        = "vault_fundamentals"
  description = "Allow Vault traffic"

  ingress {
    description      = "Vault API and cluster traffic"
    from_port        = 8200
    to_port          = 8201
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH traffic"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}
