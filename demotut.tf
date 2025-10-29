terraform {
  required_providers {
    PROVIDER_NAME = {
      source  = "hashicorp/PROVIDER_NAME"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.4.0"
}

provider "PROVIDER_NAME" {
  region = us-east-1
}

##############
# variables
##############

variable "aws_region" {
  type    = string
  default = "us-east-1"
}