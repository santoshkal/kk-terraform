# Create EBS Volume Using Terraform

# Set the name and availability_zone as per requirements
resource "aws_ebs_volume" "datacenter-volume" {
  availability_zone = "us-east-1a"
  size              = 2
  type              = "gp3"

  tags = {
    Name = "datacenter-volume"
  }
}
