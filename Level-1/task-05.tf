# Create VPC with IPv6 Using Terraform

# Update the name as per your requirements
resource "aws_vpc" "xfusion-vpc" {
# though we want to create a vpc with Amazon-provided IPV6 CIDR
# We need to define IPV4 CIDR block
cidr_block                       = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "xfusion-vpc"
  }
}

