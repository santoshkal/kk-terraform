# Create VPC with CIDR Using Terraform

# update the name and CIDR block as per requirements
resource "aws_vpc" "datacenter-vpc" {
  cidr_block = "192.168.0.0/24"

  tags = {
    Name = "datacenter-vpc"
  }
}
