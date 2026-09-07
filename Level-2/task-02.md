# Launch EC2 in Private VPC Subnet Using Terraform

The Nautilus DevOps team is expanding their AWS infrastructure and requires the setup of a private Virtual Private Cloud (VPC) along with a subnet. This VPC and subnet configuration will ensure that resources deployed within them remain isolated from external networks and can only communicate within the VPC. Additionally, the team needs to provision an EC2 instance under the newly created private VPC. This instance should be accessible only from within the VPC, allowing for secure communication and resource management within the AWS environment.

- Create a VPC named nautilus-priv-vpc with the CIDR block 10.0.0.0/16.

- Create a subnet named nautilus-priv-subnet inside the VPC with the CIDR block 10.0.1.0/24 and auto-assign IP option must not be enabled.

- Create an EC2 instance named nautilus-priv-ec2 inside the subnet and instance type must be t2.micro.

- Ensure the security group of the EC2 instance allows access only from within the VPC's CIDR block.

- Create the main.tf file (do not create a separate .tf file) to provision the VPC, subnet and EC2 instance.

- Use variables.tf file with the following variable names:

KKE_VPC_CIDR for the VPC CIDR block.
KKE_SUBNET_CIDR for the subnet CIDR block.

- Use the outputs.tf file with the following variable names:

KKE_vpc_name for the name of the VPC.
KKE_subnet_name for the name of the subnet.
KKE_ec2_private for the name of the EC2 instance.

Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.

---

# Solution:

- `main.tf`:

```tf
resource "aws_vpc" "kk_vpc" {
  cidr_block = var.KKE_VPC_CIDR

  tags = {
    Name = "nautilus-priv-vpc"
  }
}


resource "aws_subnet" "kk_subnet" {
  vpc_id                  = aws_vpc.kk_vpc.id
  cidr_block              = var.KKE_SUBNET_CIDR
  map_public_ip_on_launch = true

  tags = {
    Name = "nautilus-priv-subnet"
  }
}

resource "aws_instance" "kk_ec2" {
  ami           = "ami-016a2857e35283c3f" # Fetch the AMI using `aws ec2 describe-images`
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.kk_subnet.id

  tags = {
    Name = "nautilus-priv-ec2"
  }
}

resource "aws_security_group" "kk_sg" {
  name        = "kk-ec2-sg"
  description = "Allow access only from within the VPC"
  vpc_id      = aws_vpc.kk_vpc.id

  ingress {
    description = "Allow SSH from within VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.kk_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "kk-ec2-sg"
  }
}
```


- `variables.tf`:

```tf
variable "KKE_VPC_CIDR" {
  type    = string
  default = "10.0.0.0/16"
}

variable "KKE_SUBNET_CIDR" {
  type    = string
  default = "10.0.1.0/24"
}

```

- `outputs.tf`:

```tf
output "KKE_vpc_name" {
  description = "the name of the VPC"
  value       = aws_vpc.kk_vpc.tags["Name"]
}

output "KKE_ec2_private" {
  description = "the name of the EC2 instance"
  value       = aws_instance.kk_ec2.tags["Name"]
}
output "KKE_subnet_name" {
  description = "the name of the SUBNET"
  value       = aws_subnet.kk_subnet.tags["Name"]
}
```
