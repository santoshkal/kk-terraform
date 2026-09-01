# Create EC2 Instance Using Terraform

resource "aws_instance" "devops-ec2" {
  ami           = "ami-0c101f26f147fa7fd"
  instance_type = "t2.micro"
  key_name      = "devops-kp"
  security_groups =  ["default"]

  tags = {
    Name = "devops-ec2"
  }
}

resource "tls_private_key" "devops-kp" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "devops-kp" {
  key_name   = "devops-kp"
  public_key = tls_private_key.devops-kp.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.devops-kp.private_key_pem
  filename = "/home/bob/devops-kp.pem"
}
