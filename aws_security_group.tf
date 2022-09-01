resource "aws_security_group" "vault_sg" {
  name        = "vault_fundamentals"
  description = "Allow Vault traffic"

  ingress {
    description = "Vault Traffic"
    from_port   = 8200
    to_port     = 8201
    protocol    = "tcp"
  }

  ingress {
    description = "SSH Traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

}
