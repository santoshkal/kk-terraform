# Create IAM User Using Terraform

resource "aws_iam_user" "iamuser_siva" {
  name = "iamuser_siva"

  tags = {
    Name = "iamuser_siva"
  }
}
