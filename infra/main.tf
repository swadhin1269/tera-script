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

###########################
# OUTPUTS
###########################

output "lambda_arn" {
  value = aws_lambda_function.processor.arn
}

output "s3_bucket_name" {
  value = aws_s3_bucket.process_bucket.bucket
}
