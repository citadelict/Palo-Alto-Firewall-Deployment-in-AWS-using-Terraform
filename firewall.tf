resource "aws_instance" "palo_alto_firewall" {
  ami           = var.palo_alto_ami
  instance_type = var.firewall_instance_type
  key_name      = "devops"
  

  network_interface {
    network_interface_id = aws_network_interface.management_interface.id
    device_index         = 0
    
  }

  network_interface {
    network_interface_id = aws_network_interface.untrust_interface.id
    device_index         = 1
  }

  network_interface {
    network_interface_id = aws_network_interface.trust_interface.id
    device_index         = 2
  }

  tags = {
    Name = "Palo Alto Firewall"
  }

}



# Network Load Balancer (NLB) Configuration
resource "aws_lb" "firewall_nlb" {
  name               = "firewall-nlb"
  load_balancer_type = "network"
  subnets            = [aws_subnet.untrust_subnet.id]

  tags = {
    Name = "Palo Alto Firewall NLB"
  }
}

# Network Load Balancer Target Group (For the Firewall's Management Interface)
resource "aws_lb_target_group" "firewall_nlb_tg" {
  name        = "firewall-nlb-tg"
  port        = 443 
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = aws_vpc.firewall_vpc.id

  health_check {
    protocol            = "TCP"
    port                = 443  
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "Firewall NLB Target Group"
  }
}

# Network Load Balancer Listener for HTTPS Traffic
resource "aws_lb_listener" "firewall_nlb_listener" {
  load_balancer_arn = aws_lb.firewall_nlb.arn
  port              = 443  # Listener for HTTPS traffic
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.firewall_nlb_tg.arn
  }
}

# Attach the Palo Alto Firewall instance to the NLB Target Group
resource "aws_lb_target_group_attachment" "firewall_nlb_attachment" {
  target_group_arn = aws_lb_target_group.firewall_nlb_tg.arn
  target_id       = aws_instance.palo_alto_firewall.id
  port            = 443  # Management port (HTTPS)
}

