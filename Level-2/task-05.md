# Associate Elastic IP with EC2 Instance Using Terraform

The Nautilus DevOps Team has received a new request from the Development Team to set up a new EC2 instance. This instance will be used to host a new application that requires a stable IP address. To ensure that the instance has a consistent public IP, an Elastic IP address needs to be associated with it. This setup will help the Development Team to have a reliable and consistent access point for their application.

- Create an EC2 instance named xfusion-ec2 using any Linux AMI like Ubuntu.

- Instance type must be t2.micro and associate an Elastic IP address named xfusion-eipwith this instance.

- Use the main.tf file (do not create a separate .tf file) to provision the EC2-Instance and Elastic IP.

- Use the outputs.tf file and output the instance name using variable KKE_instance_name and the Elastic IP using variable KKE_eip.


Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.

---

# Solution:

- `main.tf`:

```tf
data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  owners = ["137112412989"] # Amazon
}


resource "aws_instance" "xfusion-ec2" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true

  tags = {
    Name = "xfusion-ec2"
  }
}

resource "aws_eip" "xfusion-eip" {
  instance = aws_instance.xfusion-ec2.id
  domain   = "vpc"

  tags = {
    Name = "xfusion-eip"
  }
}
```



- `outputs.tf`:
```tf
output "KKE_instance_name"{
    description = "Instance name"
    value = aws_instance.xfusion-ec2.tags["Name"]
}

output "KKE_eip"{
    description = "EIP name"
    value = aws_eip.xfusion-eip.public_ip
}
```
