# 1. The Trust Policy (Who can assume this role?)
data "aws_iam_policy_document" "lambda_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# 2. The IAM Role (The Identity)
resource "aws_iam_role" "ai_assistant_lambda_role" {
  name               = "govt_scheme_ai_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust_policy.json
}

# 3. The Permissions Policy (What can this role do?)
data "aws_iam_policy_document" "ai_services_policy_doc" {

  # S3 Permissions
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.raw_docs.arn}/*",
      "${aws_s3_bucket.audio_output.arn}/*"
    ]
  }
    
  # Bedrock Permissions
  statement {
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream"
    ]
    resources = ["*"] # In production, restrict this to specific model ARNs
  }

  # Translate & Polly Permissions
  statement {
    effect = "Allow"
    actions = [
      "translate:TranslateText",
      "polly:SynthesizeSpeech"
    ]
    resources = ["*"]
  }

  # DynamoDB Permissions
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem"
    ]
    resources = ["*"] # We will lock this down once we create the DynamoDB table
  }

  # CloudWatch Logging (Essential for debugging)
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

# 4. Create the actual policy resource
resource "aws_iam_policy" "ai_services_policy" {
  name        = "govt_scheme_ai_services_policy"
  description = "Allows Lambda to access Bedrock, Translate, Polly, and DynamoDB"
  policy      = data.aws_iam_policy_document.ai_services_policy_doc.json
}

# 5. Attach the policy to the role
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.ai_assistant_lambda_role.name
  policy_arn = aws_iam_policy.ai_services_policy.arn
}