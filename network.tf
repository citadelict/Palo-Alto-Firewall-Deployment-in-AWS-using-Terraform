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

# Management Subnet (Private)
resource "aws_subnet" "management_subnet" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-1c"  
  map_public_ip_on_launch = true
  tags = {
    Name = "Firewall Management Subnet"
  }
}

# Untrust/External Subnet (Public)
resource "aws_subnet" "untrust_subnet" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-1c" 
  map_public_ip_on_launch = true
  tags = {
    Name = "Untrust Subnet"
  }
}

# Trust/Internal Subnet (Private)
resource "aws_subnet" "trust_subnet" {
  vpc_id                  = aws_vpc.firewall_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-west-1c" 
  map_public_ip_on_launch = false
  tags = {
    Name = "Trust Subnet"
  }
}

# Management Route Table (Restricted)
resource "aws_route_table" "management_route_table" {
  vpc_id = aws_vpc.firewall_vpc.id
  
  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.firewall_igw.id
  }
  
  tags = {
    Name = "Management Subnet Route Table"
  }
}

# Untrust Route Table (Public)
resource "aws_route_table" "untrust_route_table" {
  vpc_id = aws_vpc.firewall_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.firewall_igw.id
  }
  
  tags = {
    Name = "Untrust Subnet Route Table"
  }
}

# Trust Route Table (Private)
resource "aws_route_table" "trust_route_table" {
  vpc_id = aws_vpc.firewall_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.firewall_igw.id
  }
  
  tags = {
    Name = "Trust Subnet Route Table"
  }
}

# Route Table Associations
resource "aws_route_table_association" "management_subnet_association" {
  subnet_id      = aws_subnet.management_subnet.id
  route_table_id = aws_route_table.management_route_table.id
}

resource "aws_route_table_association" "untrust_subnet_association" {
  subnet_id      = aws_subnet.untrust_subnet.id
  route_table_id = aws_route_table.untrust_route_table.id
}

resource "aws_route_table_association" "trust_subnet_association" {
  subnet_id      = aws_subnet.trust_subnet.id
  route_table_id = aws_route_table.trust_route_table.id
}


# Network Interfaces for Palo Alto Firewall
resource "aws_network_interface" "management_interface" {
  subnet_id   = aws_subnet.management_subnet.id 
  private_ips = ["10.0.1.10"]
  security_groups = [aws_security_group.firewall_management_sg.id]
  
  tags = {
    Name = "Firewall Management Interface"
  }
}

resource "aws_network_interface" "untrust_interface" {
  subnet_id   = aws_subnet.untrust_subnet.id 
  private_ips = ["10.0.2.10"]
  security_groups = [aws_security_group.firewall_management_sg.id]
  
  tags = {
    Name = "Firewall Untrust Interface"
  }
}

resource "aws_network_interface" "trust_interface" {
  subnet_id   = aws_subnet.trust_subnet.id 
  private_ips = ["10.0.3.10"]
  security_groups = [aws_security_group.firewall_management_sg.id]
  
  tags = {
    Name = "Firewall Trust Interface"
  }
}