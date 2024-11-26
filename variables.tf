variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "us-west-1"
}

variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
  sensitive   = true
}

variable "palo_alto_ami" {
  description = "Palo Alto VM-Series AMI ID"
  type        = string
  
}

variable "firewall_instance_type" {
  description = "EC2 Instance type for Palo Alto Firewall"
  type        = string
  default     = "m5.xlarge"
}