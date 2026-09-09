# Access Secrets Manager with IAM Role Using Terraform

To enable secure retrieval of secrets, the Nautilus DevOps team needs to configure access to a secret in AWS Secrets Manager using IAM roles and policies. The objective is to allow EC2 instances to retrieve secrets securely. Please complete the following tasks:

- Create a secret in AWS Secrets Manager named nautilus-app-secret with the following secret string:

`{"db_user":"admin","db_pass":"supersecret"}`

- Create an IAM role named nautilus-app-role with EC2 as the trusted entity.

- Attach an inline IAM policy named nautilus-app-policy that grants permission to retrieve the secret from AWS Secrets Manager.

- Use the main.tf file (do not create a separate .tf file) to provision the IAM Role and IAM Policy.

- Create the variables.tf file, ensure the following variables are defined in variables.tf file:

    - KKE_SECRET_NAME for the secret name.
    - KKE_SECRET_VALUE for the secret value.
    - KKE_ROLE_NAME for the IAM role name.
    - KKE_POLICY_NAME for the IAM policy name.

- Create the outputs.tf file, and use the following:

    - KKE_secret_name: The secret name
    - KKE_role_name: The IAM role name
    - KKE_policy_name: The IAM policy name

Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.


---

# Solution:

- `main.tf`:


```tf
# Add your code below

resource "aws_secretsmanager_secret" "kke_secret" {
  name = var.KKE_SECRET_NAME
}

resource "aws_secretsmanager_secret_version" "my_secret_manager" {
  secret_id     = aws_secretsmanager_secret.kke_secret.id
  secret_string = var.KKE_SECRET_VALUE
}

resource "aws_iam_role" "kke_role" {
  name = var.KKE_ROLE_NAME

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    NAME = var.KKE_ROLE_NAME
  }
}

resource "aws_iam_role_policy" "kke_policy" {
  name = var.KKE_POLICY_NAME
  role = aws_iam_role.kke_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.kke_secret.arn
      }
    ]
  })
}
```


- `variables.tf`:

```tf
variable "KKE_SECRET_NAME" {
  default = "nautilus-app-secret"
  type    = string
}

variable "KKE_SECRET_VALUE" {
  default = "{\"db_user\":\"admin\",\"db_pass\":\"supersecret\"}"
  type    = string
}

variable "KKE_ROLE_NAME" {
  default = "nautilus-app-role"
  type    = string
}

variable "KKE_POLICY_NAME" {
  default = "nautilus-app-policy"
  type    = string
}
```


- `outputs.tf`:

```tf
output "KKE_secret_name" {
  description = "secret name"
  value       = aws_secretsmanager_secret.kke_secret.name
}

output "KKE_role_name" {
  description = "IAM role name"
  value       = aws_iam_role.kke_role.name
}

output "KKE_policy_name" {
  description = "IAM policy name"
  value       = aws_iam_role_policy.kke_policy.name
}
```

