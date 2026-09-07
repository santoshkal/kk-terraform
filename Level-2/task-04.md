# Deploy Multiple EC2 Instances with Terraform

The Nautilus DevOps team wants to provision multiple EC2 instances in AWS using Terraform. Each instance should follow a consistent naming convention and be deployed using a modular and scalable setup.

Use Terraform to:

- Create 3 EC2 instances using the count parameter.

- Name each EC2 instance with the prefix datacenter-instance (e.g., datacenter-instance-1).

- Instances should be t2.micro.

- The key named should be datacenter-key.

- Create main.tf file (do not create a separate .tf file) to provision these instances.

- Use variables.tf file with the following:

    - KKE_INSTANCE_COUNT: number of instances.
    - KKE_INSTANCE_TYPE: type of the instance.
    - KKE_KEY_NAME: name of key used.
    - KKE_INSTANCE_PREFIX: name of the instnace.

- Use the locals.tf file to define a local variable named AMI_ID that retrieves the latest Amazon Linux 2 AMI using a data source.

- Use terraform.tfvars to assign values to the variables.

- Use outputs.tf file to output the following:

    - kke_instance_names: names of the instances created.

Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.


---

# Solution:


- `main.tf`:

```tf

resource "aws_instance" "datacenter_ec2" {

  count         = var.KKE_INSTANCE_COUNT # create three similar EC2 instances
  ami           = local.AMI_ID
  instance_type = var.KKE_INSTANCE_TYPE
  key_name      = var.KKE_KEY_NAME

# Requirement says the instance names should be `datacenter-instance-1`, `datacenter-instance-2`, etc
# We increment the index by 1.
  tags = {
    Name = "${var.KKE_INSTANCE_PREFIX}-${count.index + 1}"
  }
}


resource "tls_private_key" "datacenter-key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "datacenter-key" {
  key_name   = var.KKE_KEY_NAME
  public_key = tls_private_key.datancenter-key.public_key_openssh
}
```

- `variables.tf`:

```tf
variable "KKE_INSTANCE_COUNT" {
  type = number
}
variable "KKE_INSTANCE_TYPE" {
  type = string
}
variable "KKE_KEY_NAME" {
  type = string
}
variable "KKE_INSTANCE_PREFIX" {
  type = string
}
```

- `locals.tf`:
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

locals {
  AMI_ID = data.aws_ami.amazon_linux_2.id
}

```


- `outputs.tf`:

```tf
output "kke_instance_names" {
  description = "names of the instances created"
  value       = aws_instance.datacenter_ec2[*].tags["Name"]
}
```

- `terraform.tfvars`:

```tf
KKE_INSTANCE_COUNT  = 3
KKE_INSTANCE_TYPE   = "t2.micro"
KKE_KEY_NAME        = "datacenter-key"
KKE_INSTANCE_PREFIX = "datacenter-instance"
```
