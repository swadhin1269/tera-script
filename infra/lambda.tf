###########################
# lambda - RESOURCES
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
# CLOUDWATCH LOG GROUP
###########################

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.processor.function_name}"
  retention_in_days = 14
}