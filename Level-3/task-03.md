# Enforcing IAM Naming Standards and Permissions Using Terraform

The Nautilus DevOps team is adopting strict naming conventions for all IAM resources using Terraform. They’ve asked for help enforcing lowercase, hyphenated names based on inputs like project and team.

Your task as a DevOps engineer is to complete the following using Terraform:

- Create an IAM User The user name must be derived using the format project-team-user, all lowercase, and non-alphanumeric characters (except dashes) replaced with -.

- Create an IAM Role Use the same naming logic for the role name, ending in -role, and attach an assume role policy for EC2.

- Tagging: Both resources must be tagged with:

    - Project: xfusion
    - Team: dev-team
    - ManagedBy: Terraform
    - Env: dev

- Additionally, the IAM role should have:

    - RoleType: EC2

- Use locals block within main.tf to:

- Derive sanitized project/team names
- Create the resource name prefix
- Define reusable common tags

- Create the main.tf file (do not create a separate .tf file) to provision the IAM Role & User as per the required values.

- Use variables.tffile with the following:

    - KKE_PROJECT: name of the project(must be non-empty).
    - KKE_TEAM: name of the team (only letters, digits, dashes or underscores)
    - KKE_ENVIRONMENT: name of the environment

- Use terraform.tfvarsfile to input the values.

- Use outputs.tffile to output the following:

    - kke_user_name: name of the created user.
    - kke_role_name: name of the created role.
    - kke_tags_applied: tags applied to the IAM User.

Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.


---

# Solution:

- `main.tf`:

```tf
locals {
  # Convert project and team names to lowercase and
  # replace every character other than a-z, 0-9, or -
  # with a dash.
  sanitized_project = replace(
    lower(var.KKE_PROJECT),
    "/[^a-z0-9-]/",
    "-"
  )
  sanitized_team = replace(
    lower(var.KKE_TEAM),
    "/[^a-z0-9-]/",
    "-"
  )

  # Common resource name prefix
  resource_name_prefix = "${local.sanitized_project}-${local.sanitized_team}"

  # Tags common to both resources
  common_tags = {
    Project   = var.KKE_PROJECT
    Team      = var.KKE_TEAM
    ManagedBy = "Terraform"
    Env       = var.KKE_ENVIRONMENT
  }
}

# IAM User
resource "aws_iam_user" "kke_user" {
  name = "${local.resource_name_prefix}-user"

  tags = local.common_tags
}

# IAM Role
resource "aws_iam_role" "kke_role" {
  name = "${local.resource_name_prefix}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"

        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      RoleType = "EC2"
    }
  )
}
```


- `variables.tf`:

```tf
variable "KKE_PROJECT" {
  type = string
}

variable "KKE_TEAM" {
  type = string
}

variable "KKE_ENVIRONMENT" {
  type = string
}
```

- `terraform.tfvars`:

```tf
KKE_PROJECT = "datacenter"
KKE_TEAM = "dev-team"
KKE_ENVIRONMENT = "dev"
```

- `outputs,tf`:

```tf
output "kke_user_name" {
  description = "name of the created user"
  value       = aws_iam_user.kke_user.name
}

output "kke_role_name" {
  description = "name of the created role"
  value       = aws_iam_role.kke_role.name
}

output "kke_tags_applied" {
  description = "Tags applied to IAM User"
  value       = aws_iam_user.kke_user.tags
}
```
