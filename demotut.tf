terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.4.0"
}

provider "aws" {
  region = var.aws_region
}

##############
# variables
##############

variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "bucket_name" {
  type    = string
  default = "buck2910251037"
}

##############
# resources
##############

# Create the S3 bucket
resource "aws_s3_bucket" "process_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "trigger-bucket"
    Environment = "Dev"
  }
}

# Public access control — prevent accidental public access
resource "aws_s3_bucket_public_access_block" "process_bucket_public_access" {
  bucket = aws_s3_bucket.process_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create lifecycle configuration for Glacier + expiration
resource "aws_s3_bucket_lifecycle_configuration" "process_bucket_lifecycle" {
  bucket = aws_s3_bucket.process_bucket.id

  rule {
    id     = "move-to-glacier-and-delete"
    status = "Enabled"

    # 👇 Required even if applying to all objects
    filter {}

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}