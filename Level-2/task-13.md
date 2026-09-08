# Attach IAM Role with Inline Policy Using Terraform

The Nautilus DevOps team is setting up IAM-based access control for internal AWS resources. They need to create an IAM Role and an IAM Policy using Terraform and attach the policy to the role.

- Create an IAM Role named datacenter-role.

- Create an IAM Policy named datacenter-policy that allows listing EC2 instances.

- Attach the policy to the role

- Create the main.tf file (do not create a separate .tf file) to provision a Role, policy and attach it.

- Use the variables.tf file with the following:

    - KKE_ROLE_NAME: name of the role.
    - KKE_POLICY_NAME: name of the policy.


- Use terraform.tfvarsfile to input the role and policy names.

- Use outputs.tf file to output the following:

    - kke_iam_role_name: name of the role created.
    - kke_iam_policy_name: name of the policy ceated.

Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.


---

# Solution:

- `main.tf`:
```tf
resource "aws_iam_role" "kke_role" {
  name = var.KKE_ROLE_NAME

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = var.KKE_ROLE_NAME
  }
}

resource "aws_iam_policy" "kke_policy" {
  name = var.KKE_POLICY_NAME

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "kke_attach" {
  name       = "kke_policy_attachment"
  roles      = [aws_iam_role.kke_role.name]
  policy_arn = aws_iam_policy.kke_policy.arn
}
```

- `variables.tf`:

```tf
variable "KKE_ROLE_NAME" {
  type = string
}

variable "KKE_POLICY_NAME" {
  type = string
}
```

- `terraform.tfvars`:

```tf
KKE_ROLE_NAME = "datacenter-role"

KKE_POLICY_NAME = "datacenter-policy"
```


- `outputs.tf`:
```tf
output "kke_iam_role_name" {
  description = "name of the role"
  value       = aws_iam_role.kke_role.name
}

output "kke_iam_policy_name" {
  description = "name of the policy"
  value       = aws_iam_policy.kke_policy.name
}
```
