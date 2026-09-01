# Create Elastic IP Using Terraform

resource "aws_eip" "datacenter-eip" {
  domain = "vpc"

  tags = {
    Name = "datacenter-eip"
  }
}
