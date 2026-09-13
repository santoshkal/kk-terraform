# Create and Use Terraform Modules

The Nautilus DevOps team is implementing a production-grade, event-driven system using Terraform with workspaces and modules. The goal is to teach advanced Terraform concepts. The requirements are as follows:

1) Use two Terraform workspaces: dev and prod.

2) Implement two Terraform modules:

network module to create a VPC and a subnet.

compute module to create an EC2 instance in the subnet.

3) Use a locals block in the root module to define:

A common name prefix: devops-${terraform.workspace}.

Default tags with keys Project = devops and Environment = terraform.workspace.

4) Use main.tf file to define all resources in a structured and modular way, ensuring clarity and maintainability across modules and workspaces.

5) Use variables.tf file from the root module with the following variable names:

KKE_VPC_CIDR:cidr block for the vpc.(10.0.0.0/16)

KKE_INSTANCE_TYPE: EC2 instance type.

6) Use validation in the variables.tf file to ensure that KKE_INSTANCE_TYPE only accepts t3.micro or t3.large, and display an appropriate error message if any other value is provided.

7) The modules must merge the incoming tags with resource-specific Name tags.

8) Use dev.tfvars and prod.tfvars files with the following:

In dev.tfvars: KKE_INSTANCE_TYPE= t3.micro
In prod.tfvars: KKE_INSTANCE_TYPE =t3.large

9) Use outputs.tf file from the root module with the following output names:

kke_vpc_name: Name of the created VPC.
kke_subnet_name: Name of the created Subnet.
kke_instance_name: Name of the created EC2 instance.

10) Network Module:

Use variables.tf file from the network module with the following variable names:

KKE_NAME_PREFIX: Name prefix to use for network resources.

KKE_VPC_CIDR: CIDR block for the VPC.

KKE_TAGS: Common tags map for network resources.

11) Use outputs.tf file from the network module with the following output names:

kke_vpc_name: Name of the created VPC.

kke_subnet_name: Name of the created Subnet.

12) Compute Module:

Use the Amazon Linux 2 AMI image with ID ami-0c94855ba95c71c99 for the EC2 instance in the compute module.

13) Use variables.tf file from the compute module with the following variable names:

KKE_NAME_PREFIX: Name prefix to use for compute resources.
KKE_SUBNET_ID: Subnet ID where the instance will be created.
KKE_INSTANCE_TYPE: EC2 instance type.
KKE_TAGS: Common tags map for compute resources.

14) Use outputs.tf file from the compute module with the following output names:

kke_instance_name: Name of the created EC2 instance.

Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration. You may need to run terraform apply multiple times.

---

# Solution:

## Directory structure:

```
.
├── README.MD
├── dev.tfvars
├── main.tf
├── modules
│   ├── compute
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── network
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── outputs.tf
├── prod.tfvars
├── provider.tf
└── variables.tf
```


- `./main.tf`:

```tf
locals {
  name_prefix = "devops-${terraform.workspace}"

  default_tags = {
    Project     = "devops"
    Environment = "${terraform.workspace}"
  }
}

module "network" {
  source = "./modules/network"

  KKE_NAME_PREFIX = local.name_prefix
  KKE_VPC_CIDR    = var.KKE_VPC_CIDR
  KKE_TAGS        = local.default_tags
}

module "compute" {
  source = "./modules/compute"

  KKE_NAME_PREFIX   = local.name_prefix
  KKE_SUBNET_ID     = module.network.kke_subnet_id
  KKE_INSTANCE_TYPE = var.KKE_INSTANCE_TYPE
  KKE_TAGS          = local.default_tags
}
```


- `variables.tf`:

```tf
variable "KKE_VPC_CIDR" {
  type = string

  default = "10.0.0.0/16"
}

variable "KKE_INSTANCE_TYPE" {
  type = string

  validation {
    condition     = contains(["t3.micro", "t3.large"], var.KKE_INSTANCE_TYPE)
    error_message = "Instanace type should be either 't3.micro' or 't3.large'"
  }
}
```


- `dev.tfvars`:

```tf
KKE_INSTANCE_TYPE = "t3.micro"
```

- `prod.tfvars`: 

```tf
KKE_INSTANCE_TYPE = "t3.large"
```


- `outputs.tf`:


```tf
output "kke_vpc_name" {
  description = "Name of the created VPC"
  value       = module.network.kke_vpc_name
}

output "kke_subnet_name" {
  description = "Name of the created Subnet"
  value       = module.network.kke_subnet_name
}

output "kke_instance_name" {
  description = "Name of the created EC2 instance"
  value       = module.compute.kke_instance_name
}
```


## Compute module:

`./modules/compute/main.tf`:

```tf
resource "aws_instance" "kke_instance" {
  ami           = "ami-0c94855ba95c71c99"
  instance_type = var.KKE_INSTANCE_TYPE
  subnet_id     = var.KKE_SUBNET_ID

  tags = merge(
    var.KKE_TAGS,
    {
      Name = "${var.KKE_NAME_PREFIX}-instance"
    }
  )
}
```

- `./modules/compute/variables.tf`:

```tf
variable "KKE_NAME_PREFIX" {
  description = "Name prefix to use for compute resources"
  type        = string
}

variable "KKE_SUBNET_ID" {
  description = "Subnet ID where the instance will be created"
  type        = string
}

variable "KKE_INSTANCE_TYPE" {
  description = "EC2 instance type"
  type        = string
}

variable "KKE_TAGS" {
  description = "Common tags map for compute resources"
  type        = map(string)
}
```

- `outputs.tf`:

```tf
output "kke_instance_name" {
  description = "Name of the created EC2 instance"
  value       = aws_instance.kke_instance.tags["Name"]
}
```

## Network module:

- `./modules/network/main.tf`:

```tf
resource "aws_vpc" "kke_vpc" {
  cidr_block = var.KKE_VPC_CIDR

  tags = merge(
    var.KKE_TAGS,
    {
      Name = "${var.KKE_NAME_PREFIX}-vpc"
    }
  )
}

resource "aws_subnet" "kke_subnet" {
  vpc_id     = aws_vpc.kke_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = merge(
    var.KKE_TAGS,
    {
      Name = "${var.KKE_NAME_PREFIX}-subnet"
    }
  )
}
```

- `./modules/network/variables.tf`:

```tf
variable "KKE_NAME_PREFIX" {
  description = "Name prefix to use for network resources"
  type        = string
}

variable "KKE_VPC_CIDR" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "KKE_TAGS" {
  description = "Common tags map for network resources"
  type        = map(string)
}
```

- `./modules/network/outputs.tf`:

```tf
output "kke_vpc_name" {
  description = "Name of the created VPC"
  value       = aws_vpc.kke_vpc.tags["Name"]
}

output "kke_subnet_name" {
  description = "Name of the created Subnet"
  value       = aws_subnet.kke_subnet.tags["Name"]
}

output "kke_subnet_id" {
  description = "ID of the created subnet"
  value       = aws_subnet.kke_subnet.id
}
```

## Apply workspace configs

- Create workspaces:
```bash
# Create workspaces dev and prod

terraform workspace new dev

terraform workdspace new prod

# Switch to dev workspace

terraform workspace select dev

# Apply dev workspace configs

terraform apply -var-file=dev.tfvars

# Verify if all resource created 

terraform plan -var-file=dev.tfvars

# Switch to prod workspace

terraform workspace select prod

# Apply prod configs

terraform apply -var-file=prod-tfvars

# Validate if all resource provisioned

terraform plan -var-file=prod-tfvars
```

