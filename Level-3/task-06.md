# Deploying a Multi-Tier Architecture on AWS Using Terraform

The DevOps team needs to build a secure, modular multi-tier AWS infrastructure to support a modern cloud-native application stack using Terraform. As part of this requirement, use only allowed AWS services and ensure secure variable usage.

As a member of the Nautilus DevOps Team, your tasks are:

- Create a DynamoDB Table: Provision a table named nautilus-app-table with minimal configuration.

- Create an SNS Topic: Set up a topic named nautilus-app-topic for messaging and notifications.

- Create an SSM Parameter: Store a sensitive configuration value in AWS SSM Parameter Store under the name /nautilus/app/config.

- Create main.tf file (do not create a separate .tf file) to provision a dynamoDB table, sns-topic and ssm parameter.

- Use variables.tf file with the following:

    - KKE_ENVIRONMENT: devEnvironment.
    - KKE_DYNAMODB_TABLE_NAME: name of dynamodb table.
    - KKE_SNS_TOPIC_NAME: name of the sns topic.
    - KKE_SSM_PARAM_NAME: name of the SSM parameter.

- Create terraform.tfvars to input the name of the variables.

- Use outputs.tf file to output the following:

    - kke_dynamodb_table_name: name of the dynamodb table.
    - kke_sns_topic_arn: arn of the sns-topic created.
    - kke_ssm_parameter_name: name of the ssm parameter created.


Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.


---

# Solution:

- `main.tf`:

```tf
resource "aws_dynamodb_table" "kke_dynamodb_table" {
  name           = var.KKE_DYNAMODB_TABLE_NAME
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "UserId"

  attribute {
    name = "UserId"
    type = "S"
  }

  tags = {
    Name        = var.KKE_DYNAMODB_TABLE_NAME
    Environment = var.KKE_ENVIRONMENT
  }
}

resource "aws_sns_topic" "kke_sns" {
  name = var.KKE_SNS_TOPIC_NAME

  tags = {
    Name        = var.KKE_SNS_TOPIC_NAME
    Environment = var.KKE_ENVIRONMENT
  }
}

resource "aws_ssm_parameter" "kke_ssm_param" {
  name  = var.KKE_SSM_PARAM_NAME
  type  = "SecureString"
  value = "bar"

  tags = {
    Environment = var.KKE_ENVIRONMENT
    Name        = var.KKE_SSM_PARAM_NAME
  }
}
```


- `variables.tf`:

```tf
variable "KKE_ENVIRONMENT" {
  type = string
}

variable "KKE_DYNAMODB_TABLE_NAME" {
  type = string
}

variable "KKE_SNS_TOPIC_NAME" {
  type = string
}

variable "KKE_SSM_PARAM_NAME" {
  type = string
}
```

- `terraform.tfvars`:

```tf
KKE_ENVIRONMENT         = "dev"
KKE_DYNAMODB_TABLE_NAME = "nautilus-app-table"
KKE_SNS_TOPIC_NAME      = "nautilus-app-topic"
KKE_SSM_PARAM_NAME      = "/nautilus/app/config"
```


- `outputs.tf`:

```tf
output "kke_dynamodb_table_name" {
  description = "name of the dynamodb table"
  value       = aws_dynamodb_table.kke_dynamodb_table.name
}

output "kke_sns_topic_arn" {
  description = "arn of the sns-topic created"
  value       = aws_sns_topic.kke_sns.arn
}

output "kke_ssm_parameter_name" {
  description = " name of the ssm parameter created"
  value       = aws_ssm_parameter.kke_ssm_param.name
}
```
