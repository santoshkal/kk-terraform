# Attach IAM Policy for DynamoDB Access Using Terraform

The DevOps team has been tasked with creating a secure DynamoDB table and enforcing fine-grained access control using IAM. This setup will allow secure and restricted access to the table from trusted AWS services only.

As a member of the Nautilus DevOps Team, your task is to perform the following using Terraform:

- Create a DynamoDB Table: Create a table named devops-table with minimal configuration.

- Create an IAM Role: Create an IAM role named devops-role that will be allowed to access the table.

- Create an IAM Policy: Create a policy named devops-readonly-policy that should grant read-only access (GetItem, Scan, Query) to the specific DynamoDB table and attach it to the role.

- Create the main.tf file (do not create a separate .tf file) to provision the table, role, and policy.

- Create the variables.tf file with the following variables:

    - KKE_TABLE_NAME: name of the DynamoDB table
    - KKE_ROLE_NAME: name of the IAM role
    - KKE_POLICY_NAME: name of the IAM policy

- Create the outputs.tf file with the following outputs:

    - kke_dynamodb_table: name of the DynamoDB table
    - kke_iam_role_name: name of the IAM role
    - kke_iam_policy_name: name of the IAM policy

- Define the actual values for these variables in the terraform.tfvars file.

Ensure that the IAM policy allows only read access and restricts it to the specific DynamoDB table created.


Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.

---
# Solution:

- `main.tf`:

```tf
resource "aws_dynamodb_table" "kke_dynamodb_table" {
  name           = var.KKE_TABLE_NAME
  hash_key       = "UserId"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1


  attribute {
    name = "UserId"
    type = "S"
  }

  tags = {
    Name = var.KKE_TABLE_NAME
  }
}

resource "aws_iam_role" "kke_role" {
  name = var.KKE_ROLE_NAME

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
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
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.kke_dynamodb_table.arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.kke_role.name
  policy_arn = aws_iam_policy.kke_policy.arn
}
```


- `variables.tf`:

```tf
variable "KKE_TABLE_NAME" {
  type = string
}

variable "KKE_ROLE_NAME" {
  type = string
}

variable "KKE_POLICY_NAME" {
  type = string
}
```


- `terraform.tfvars`:

```tf
KKE_TABLE_NAME  = "devops-table"
KKE_ROLE_NAME   = "devops-role"
KKE_POLICY_NAME = "devops-readonly-policy"
```

- `outputs.tf`:

```tf
output "kke_dynamodb_table" {
  description = "name of the DynamoDB table"
  value       = aws_dynamodb_table.kke_dynamodb_table.name
}

output "kke_iam_role_name" {
  description = "name of the IAM Role"
  value       = aws_iam_role.kke_role.name
}

output "kke_iam_policy_name" {
  description = "Name of the IAM Policy"
  value       = aws_iam_policy.kke_policy.name
}
```
