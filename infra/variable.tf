###########################
# VARIABLES
###########################

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "ap-south-1"
}

variable "bucket_name" {
  description = "S3 bucket name (if needed for lambda or storage)"
  type        = string
  default     = "buck2910251037"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "my_ip_cidr" {
  description = "Your IP address in CIDR format (e.g., 203.0.113.5/32)"
  type        = string
  default     = "0.0.0.0/0" # allows SSH from anywhere (not recommended)
}
