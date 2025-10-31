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

# output "lambda_arn" {
#   value = aws_lambda_function.processor.arn
# }

# output "s3_bucket_name" {
#   value = aws_s3_bucket.process_bucket.bucket
# }

output "instance_id" {
  value = aws_instance.web.id
}

output "public_ip" {
  value = aws_instance.web.public_ip
}

output "public_dns" {
  value = aws_instance.web.public_dns
}

