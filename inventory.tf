resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tmpl",
    {
      google = tomap({
        for instance in google_compute_instance.google_vault :
        instance.name => instance.network_interface.0.access_config.0.nat_ip
      })
      azure = tomap({
        for instance in azurerm_linux_virtual_machine.azure_vault :
        instance.name => instance.public_ip_address
      })
      aws = tomap({
        for instance in aws_instance.aws_vault :
        instance.tags.Name => instance.public_ip
      })
    }
  )
  filename = "../ansible/inventory"
}
