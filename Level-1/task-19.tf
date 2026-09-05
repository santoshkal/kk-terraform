# Create SSM Parameter Using Terraform

resource "aws_ssm_parameter" "nautilus-ssm-parameter" {
  name  = "nautilus-ssm-parameter"
  type  = "String"
  value = "nautilus-value"

  tags = {
    Name = "nautilus-ssm-parameter"
  }
}


