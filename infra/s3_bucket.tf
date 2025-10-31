# ###########################
# # S3 - RESOURCES
# ###########################

# # Create the S3 bucket
# resource "aws_s3_bucket" "process_bucket" {
#   bucket = var.bucket_name

#   tags = {
#     Name        = "trigger-bucket"
#     Environment = "Dev"
#   }
# }

# # Public access control — prevent accidental public access
# resource "aws_s3_bucket_public_access_block" "process_bucket_public_access" {
#   bucket = aws_s3_bucket.process_bucket.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# # Create lifecycle configuration for Glacier + expiration
# resource "aws_s3_bucket_lifecycle_configuration" "process_bucket_lifecycle" {
#   bucket = aws_s3_bucket.process_bucket.id

#   rule {
#     id     = "move-to-glacier-and-delete"
#     status = "Enabled"

#     # 👇 Required even if applying to all objects
#     filter {}

#     transition {
#       days          = 30
#       storage_class = "GLACIER"
#     }

#     expiration {
#       days = 365
#     }
#   }
# }

# ###########################
# # ALLOW S3 TO INVOKE LAMBDA
# ###########################

# resource "aws_lambda_permission" "allow_s3_invoke" {
#   statement_id  = "AllowS3Invoke"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.processor.function_name
#   principal     = "s3.amazonaws.com"
#   source_arn    = aws_s3_bucket.process_bucket.arn
# }

# ###########################
# # S3 → LAMBDA TRIGGER
# ###########################

# resource "aws_s3_bucket_notification" "lambda_trigger" {
#   bucket = aws_s3_bucket.process_bucket.id

#   lambda_function {
#     lambda_function_arn = aws_lambda_function.processor.arn
#     events              = ["s3:ObjectCreated:*"]
#   }

#   depends_on = [
#     aws_lambda_function.processor,
#     aws_lambda_permission.allow_s3_invoke,
#     aws_iam_role_policy_attachment.lambda_basic_policy
#   ]
# }