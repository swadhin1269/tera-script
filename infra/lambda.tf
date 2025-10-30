######################
# IAM Role for Lambda
######################

# Create IAM Role
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

######################
# Lambda Function
######################

resource "aws_lambda_function" "processor" {
  function_name = "s3-trigger-lambda"
  filename      = "lambda_payload.zip"       # Zip file name
  handler       = "index.handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_exec_role.arn  # 👈 New Role Reference
}

output "lambda_arn" {
  value = aws_lambda_function.processor.arn
}
