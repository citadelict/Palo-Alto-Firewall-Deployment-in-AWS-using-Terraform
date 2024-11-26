resource "aws_vpc" "firewall_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  
  tags = {
    Name = "Palo Alto Firewall VPC"
  }
}

resource "aws_internet_gateway" "firewall_igw" {
  vpc_id = aws_vpc.firewall_vpc.id
  
  tags = {
    Name = "Firewall VPC Internet Gateway"
  }
}


resource "aws_subnet" "management_subnet" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-1c"  
  map_public_ip_on_launch = true

  tags = {
    Name = "Management Subnet"
  }
}

resource "aws_subnet" "data_subnet" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-1c" 

  tags = {
    Name = "Data Subnet"
  }
}

# Route Table for Management Subnet
resource "aws_route_table" "management_route_table" {
  vpc_id = aws_vpc.firewall_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.firewall_igw.id
  }

  tags = {
    Name = "Management Subnet Route Table"
  }
}

# Route Table for Data Subnet
resource "aws_route_table" "data_route_table" {
  vpc_id = aws_vpc.firewall_vpc.id

  tags = {
    Name = "Data Subnet Route Table"
  }
}

# Route Table Associations
resource "aws_route_table_association" "management_subnet_association" {
  subnet_id      = aws_subnet.management_subnet.id
  route_table_id = aws_route_table.management_route_table.id
}

resource "aws_route_table_association" "data_subnet_association" {
  subnet_id      = aws_subnet.data_subnet.id
  route_table_id = aws_route_table.data_route_table.id
}

# Network Interface for Management
resource "aws_network_interface" "management_interface" {
  subnet_id       = aws_subnet.management_subnet.id
  private_ips     = ["10.0.1.10"]  # Static private IP in management subnet
  security_groups = [aws_security_group.firewall_management_sg.id]

  tags = {
    Name = "Palo Alto Management Interface"
  }
}

# Network Interface for Data Plane
resource "aws_network_interface" "data_interface" {
  subnet_id   = aws_subnet.data_subnet.id
  private_ips = ["10.0.2.10"]  # Static private IP in data subnet

  tags = {
    Name = "Palo Alto Data Interface"
  }
}

# Elastic IP for Management Interface
resource "aws_eip" "management_eip" {
  domain                    = "vpc"
  depends_on = [aws_instance.palo_alto_firewall]
  network_interface = aws_network_interface.management_interface.id

  tags = {
    Name = "Management Interface Elastic IP"
  }
}
