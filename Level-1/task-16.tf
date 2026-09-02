# Create IAM Policy Using Terraform

resource "aws_iam_policy" "policy" {
  name        = "iampolicy_yousuf"
  path        = "/"
  description = "My KK policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeImages",
          "ec2:DescribeSnapshots"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
