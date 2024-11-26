resource "aws_instance" "palo_alto_firewall" {
  ami           = var.palo_alto_ami
  instance_type = var.firewall_instance_type
  key_name      = "devops"

  network_interface {
    network_interface_id = aws_network_interface.management_interface.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.data_interface.id
    device_index         = 1
  }

  tags = {
    Name = "Palo Alto Firewall"
  }
}
