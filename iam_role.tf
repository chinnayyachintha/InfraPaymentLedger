# IAM Role for Lambda function to access DynamoDB, Secrets Manager, VPC, and CloudWatch Logs
resource "aws_iam_role" "lambda_role" {
  name = "${var.vpc_name}-lambda-vpc-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
      }
    ]
  })
}

# Attach the combined policy for Lambda access to all required services
resource "aws_iam_role_policy" "lambda_role_policy" {
  name = "${var.vpc_name}-lambda-vpc-execution-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # DynamoDB access for PutItem, GetItem, Query, UpdateItem
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:UpdateItem"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      # Secrets Manager access to GetSecretValue and DescribeSecret
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      # VPC access for managing network interfaces and describing resources
      {
        Action = [
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AttachNetworkInterface"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      # CloudWatch Logs access for creating log groups and streams
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
