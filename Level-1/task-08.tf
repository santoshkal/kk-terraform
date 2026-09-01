# Create AMI Using Terraform

resource "aws_ami_from_instance" "xfusion-ec2-ami" {
  name               = "xfusion-ec2-ami"
# get the source_instance_id from the state file
  source_instance_id = "i-865507790db40e672"

  tags = {
    Name = "xfusion-ec2-ami"
  }
}

# Provision EC2 instance
resource "aws_instance" "ec2" {
  ami           = "ami-0c101f26f147fa7fd"
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    "sg-34dc213504ab9970f"
  ]

  tags = {
    Name = "xfusion-ec2"
  }
}

# Run `aws ec2 describe-images --owners self` to get the status if AMI for available state.
