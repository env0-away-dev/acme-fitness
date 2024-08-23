
resource "aws_iam_role" "env0_cost_role" {
  name = var.cost_assume_role_name

  max_session_duration = 3600 # env0 requirement, 5 hours for SaaS

  # 913128560466 is env0's AWS Account ID
  # see: https://docs.env0.com/docs/connect-your-cloud-account#using-aws-assume-role
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::913128560467:root"
        },
        "Action" : "sts:AssumeRole",
        "Condition" : {
          "StringEquals" : {
            "sts:ExternalId" : "${local.org_id}"
          }
        }
      }
    ]
  })

  inline_policy {
    name = "${var.assume_role_name}-cost-policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Resource = "*"
        Action   = "ce:GetCostAndUsage"
        Effect   = "Allow"
      },
    ]
    })
  }

  tags = {
    note    = "Created through env0 Bootstrap"
    purpose = "Allow env0 Cost Management features"
  }
}

resource "env0_aws_cost_credentials" "aws_cost_credentials" {
  name     = aws_iam_role.env0_cost_role.arn
  arn      = aws_iam_role.env0_cost_role.arn
  duration = 3600
}
