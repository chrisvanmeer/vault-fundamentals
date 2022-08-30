resource "aws_key_pair" "key" {
  key_name   = var.aws_key_pair_key_name
  public_key = file(var.ssh_public_key_location)
}

resource "aws_kms_key" "autounseal_key" {
  description             = "Vault Fundamentals auto unseal key"
  deletion_window_in_days = 7
  policy                  = templatefile("kms-key-policy.json")
}

resource "aws_kms_alias" "autounseal_alias" {
  name          = "alias/vault-fundamentals-unseal-key"
  target_key_id = aws_kms_key.autounseal_key.key_id
}
