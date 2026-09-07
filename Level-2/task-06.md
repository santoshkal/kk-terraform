# Launch EC2 Instance from Custom AMI Using Terraform

The Nautilus DevOps team needs to create an AMI from an existing EC2 instance for backup and scaling purposes. The following steps are required:

- They have an existing EC2 instance named datacenter-ec2.

- They need to create an AMI named datacenter-ec2-ami from this instance.

- Additionally, they need to launch a new EC2 instance named datacenter-ec2-new using this AMI.

- Update the main.tf file (do not create a different or separate.tf file) to provision an AMI and then launch an EC2 Instance from that AMI.

- Create an outputs.tf file to output the following values:

    - KKE_ami_id for the AMI ID you created.
    - KKE_new_instance_id for the EC2 instance ID you created.

Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.

---

# Solution:


- `main.tf`:

```tf
# Provision EC2 instance
resource "aws_instance" "ec2" {
  ami           = "ami-0c101f26f147fa7fd"
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    "sg-8254e2e7657e3c2b7"
  ]

  tags = {
    Name = "datacenter-ec2"
  }
}

resource "aws_ami_from_instance" "datacenter-ec2-ami" {
  name               = "datacenter-ec2-ami"
  source_instance_id = aws_instance.ec2.id

  tags = {
    Name = "datacenter-ec2-ami"
  }
}

resource "aws_instance" "ec2-new" {
  ami           = aws_ami_from_instance.datacenter-ec2-ami.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    "sg-8254e2e7657e3c2b7"
  ]

  tags = {
    Name = "datacenter-ec2-new"
  }
}

```


- `outputs.tf`:

```tf
output "KKE_ami_id"{
    description = "New  the AMI ID"
    value = aws_ami_from_instance.datacenter-ec2-ami.id
}

output "KKE_new_instance_id"{
    description = "New EC2 instance ID"
    value = aws_instance.ec2-new.id
}
```
