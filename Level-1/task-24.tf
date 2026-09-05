# Change Instance Type Using Terraform


# Provision EC2 instance
resource "aws_instance" "ec2" {
  ami           = "ami-0c101f26f147fa7fd"
# Update the instance_type to `t2.nano`
  instance_type = "t2.nano"
  subnet_id     = ""
  vpc_security_group_ids = [
    "sg-41cd47f9d611d84f8"
  ]

  tags = {
    Name = "xfusion-ec2"
  }
}
