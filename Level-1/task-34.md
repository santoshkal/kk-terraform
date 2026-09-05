# Security Group Variable Setup Using Terraform

The Nautilus DevOps team is enhancing infrastructure automation and needs to provision a Security Group using Terraform with specific configurations.

For this task, create an AWS Security Group using Terraform with the following requirements:

The Security Group name xfusion-sg should be stored in a variable named KKE_sg.
Note:

1. The configuration values should be stored in a variables.tf file.

2. The Terraform script should be structured with a main.tf file referencing variables.tf.
The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.


---
# Solution:

- `variables.tf`

```tf
variable "KKE_sg" {
  type    = string
  default = "xfusion-sg"
}
```

- `main.tf`

```tf
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_security_group" "kke-sg" {
  name   = var.KKE_sg
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.KKE_sg
  }
}
```
