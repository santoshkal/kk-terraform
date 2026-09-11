# Storing and Accessing Sensitive Data Securely with AWS Secrets Manager Using Terraform

The Nautilus DevOps team needs to securely manage sensitive information using AWS Secrets Manager. The task is to create a secret in AWS Secrets Manager using Terraform. Store a database password securely in this secret. Ensure the password is passed as a sensitive Terraform variable, and it should not appear in Terraform logs or output without being marked sensitive.

Requirements:

- Create an AWS Secrets Manager secret named xfusion-db-password.

- Store the database password SuperSecretPassword123! in the secret using Terraform.

- Mark the Terraform variable for the password as sensitive.

- Do not expose the actual password in Terraform outputs without marking it sensitive.

- Create main.tf file (do not create a separate .tf file) to provision a Secret and add the database password in it.

- Use variables.tffile for the following:

    - KKE_DB_PASSWORD: database password stored in secrets manager.

- Create a terraform.tfvars to input the database password.

- Use outputs.tf file to output the following:

    - kke_secret_arn: arn of the secret created.

    - kke_secret_string: database password.


Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.


--- 

# Solution:

- `main.tf`:

```tf
resource "aws_secretsmanager_secret" "kke_secret_manager" {
  name = var.kke_secret_manager
}

resource "aws_secretsmanager_secret_version" "kke_secret" {
  secret_id     = aws_secretsmanager_secret.kke_secret_manager.id
  secret_string = var.KKE_DB_PASSWORD
}
```

- `variables.tf`:

```tf
variable "KKE_DB_PASSWORD" {
  type      = string
  sensitive = true
}

variable "kke_secret_manager" {
  type = string
}
```

- `terraform.tfvars`:

```tf
KKE_DB_PASSWORD    = "SuperSecretPassword123!"
kke_secret_manager = "xfusion-db-password"
```

- `outputs.tf`:

```tf
output "kke_secret_arn" {
  description = "arn of the secret created"
  value       = aws_secretsmanager_secret_version.kke_secret.arn
}

output "kke_secret_string" {
  description = "database password"
  value       = aws_secretsmanager_secret_version.kke_secret.secret_string
  sensitive   = true
}
```
