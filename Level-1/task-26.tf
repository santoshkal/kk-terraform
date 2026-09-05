# Attach Policy Using Terraform

# Create IAM user
resource "aws_iam_user" "user" {
  name = "iamuser_mariyam"

  tags = {
    Name = "iamuser_mariyam"
  }
}

# Create IAM Policy
resource "aws_iam_policy" "policy" {
  name        = "iampolicy_mariyam"
  description = "IAM policy allowing EC2 read actions for mariyam"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:Read*"]
        Resource = "*"
      }
    ]
  })
}

# Add this policy_attachement block
resource "aws_iam_policy_attachment" "kk-attach" {
  name       = "kk-attachment"
  users      = [aws_iam_user.user.name]
  policy_arn = aws_iam_policy.policy.arn
}
