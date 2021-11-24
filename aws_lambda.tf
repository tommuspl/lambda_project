# Przygotuj lambdę w języku python, 
# lambda powinna po odpaleniu  wylistować wszystkich użytkowników (IAM users), 
# następnie sprawdzić podpięte uprawnienia.  
# W przypadku wykrycia, że jedną z podpiętych polityk jest AdministratorAccess, 
# wtedy lambda powinna odpiąć tę politykę. 
# Wraz z lambdą dostarcz proszę instrukcję jak ją zdeployować.


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
  access_key = "XXXXX"
  secret_key = "YYYYY"
}

resource "aws_iam_role" "role_for_lambda" {
  name = "role_for_lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy_for_lambda" {
  name        = "policy_for_lambda"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:*",
        "organizations:DescribeAccount",
        "organizations:DescribeOrganization",
        "organizations:DescribeOrganizationalUnit",
        "organizations:DescribePolicy",
        "organizations:ListChildren",
        "organizations:ListParents",
        "organizations:ListPoliciesForTarget",
        "organizations:ListRoots",
        "organizations:ListPolicies",
        "organizations:ListTargetsForPolicy"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.role_for_lambda.name
  policy_arn = aws_iam_policy.policy_for_lambda.arn
}

resource "aws_lambda_function" "users_permissions" {
  filename = "functions_container.zip"
  function_name = "users_permissions"
  role = aws_iam_role.role_for_lambda.arn
  handler = "admin_access.list_users_and_check_permissions"

  source_code_hash = filebase64sha256("functions_container.zip")

  runtime = "python3.9"
}

output "function_name" {
  description = "Name of the Lambda function."

  value = aws_lambda_function.users_permissions.function_name
}