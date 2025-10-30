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
# VARIABLES
###########################

variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "bucket_name" {
  type    = string
  default = "buck2910251037"
}

###########################
# RESOURCES
###########################

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

###########################
# IAM Role for Lambda
###########################

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AWS Managed Policy for Lambda basic execution
resource "aws_iam_role_policy_attachment" "lambda_basic_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

###########################
# LAMBDA FUNCTION
###########################

resource "aws_lambda_function" "processor" {
  function_name = "s3-trigger-lambda"
  filename      = "lambda_payload.zip"       # Zip file in same directory
  handler       = "index.handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_exec_role.arn
  source_code_hash = filebase64sha256("lambda_payload.zip")
}

###########################
# ALLOW S3 TO INVOKE LAMBDA
###########################

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.process_bucket.arn
}

###########################
# S3 → LAMBDA TRIGGER
###########################

resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = aws_s3_bucket.process_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_lambda_function.processor,
    aws_lambda_permission.allow_s3_invoke,
    aws_iam_role_policy_attachment.lambda_basic_policy
  ]
}

###########################
# CLOUDWATCH LOG GROUP
###########################

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.processor.function_name}"
  retention_in_days = 14
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
