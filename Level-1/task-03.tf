# Create VPC Using Terraform

# update the name as per description
resource "aws_vpc" "nautilus-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "nautilus-vpc"
  }
}
