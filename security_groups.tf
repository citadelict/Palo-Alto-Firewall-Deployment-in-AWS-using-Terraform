resource "aws_security_group" "firewall_management_sg" {
  name        = "Palo Alto Management SG"
  description = "Security group for Palo Alto firewall management interface"
  vpc_id      = aws_vpc.firewall_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   tags = {
    Name = "Firewall Management Security Group"
  }
}