
# 1. Automatically package the source code directory
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../handler"
  output_path = "${path.module}/lambda_function.zip"
}

# 2. Provision the Central AI Engine Lambda
resource "aws_lambda_function" "scheme_eligibility_engine" {
  function_name = "${var.project_name}-scheme-eligibility-engine"
  role          = aws_iam_role.ai_assistant_lambda_role.arn

  # Deployment package parameters
  filename = data.archive_file.lambda_zip.output_path
  # Fix: Use the correct exported base64 attribute
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  # Execution configuration
  handler     = "app.lambda_handler"
  runtime     = "python3.12"
  timeout     = 180 # 3 minutes to accommodate sequential language translation and LLM generation
  memory_size = 512 # Generative AI orchestration libraries run faster with higher memory allocation

  # Inject database reference into runtime environment
  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.user_session_context.arn
    }
  }
}

# 3. Explicitly manage the CloudWatch Log Group lifecycle
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.scheme_eligibility_engine.function_name}"
  retention_in_days = 14
}