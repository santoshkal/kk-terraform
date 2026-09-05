# Create VPC and Subnet Using Terraform

To ensure proper resource provisioning order, the DevOps team wants to explicitly define the dependency between an AWS VPC and a Subnet. The objective is to create a VPC and then a Subnet that explicitly depends on it using Terraform's depends_on argument.

Please complete the following tasks:

1. Create a VPC named devops-vpc.

2. Create a Subnet named devops-subnet.

3. Ensure the Subnet uses the depends_on argument to explicitly depend on the VPC resource.

4. Create the main.tf file (do not create a separate .tf file) to provision a VPC and Subnet.

5. Use variables.tf, define the following variables:

    - KKE_VPC_NAME for the VPC name.
    - KKE_SUBNET_NAME for the Subnet name.

6. Use terraform.tfvars to input the names of the VPC and subnet.

7. In outputs.tf, output the following:

    - kke_vpc_name: The name of the VPC.
    - kke_subnet_name: The name of the Subnet.

Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.

---

# Solution


- `main.tf`:
resource "aws_vpc" "kk_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = var.KKE_VPC_NAME
  }
}

resource "aws_subnet" "kk_subnet" {
  vpc_id     = aws_vpc.kk_vpc.id
  cidr_block = "10.0.1.0/24"

  depends_on = [
    aws_vpc.kk_vpc
  ]
  tags = {
    Name = var.KKE_SUBNET_NAME
  }
}
```tf

```


- `variables.tf`:

```tf
```
variable "KKE_VPC_NAME" {
  type = string
}

variable "KKE_SUBNET_NAME" {
  type = string
}

- `terraform.tfvars`:

```tf
KKE_VPC_NAME = "devops-vpc"

KKE_SUBNET_NAME = "devops-subnet"

```

- `outputs.tf`:
output "kke_vpc_name" {
  description = "The name of the VPC"
  value       = aws_vpc.kk_vpc.tags["Name"]
}

output "kke_subnet_name" {
  description = "The name of the Subnet"
  value       = aws_subnet.kk_subnet.tags["Name"]
}
```tf
```



