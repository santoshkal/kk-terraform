# Create DynamoDB Table Using CloudFormation Using Terraform

The Nautilus DevOps team wants to automate infrastructure provisioning using CloudFormation. As part of the stack setup, they need to create a DynamoDB table.

- Create a CloudFormation stack named xfusion-dynamodb-stack.

The stack must create a DynamoDB table named xfusion-cf-dynamodb-table.

- Use the main.tf file (do not create a separate .tf file) to provision a CloudFormation stack and DynamoDB table. Make sure to add a lifecycle block in main.tf to ignore changes to the parameters attribute.

- Use the variables.tf file with the following variable names:

    - KKE_DYNAMODB_TABLE_NAME: Dynamodb table name.

- The locals.tf file is already provided and includes the following:

    - cf_template_body: A local variable that stores the CloudFormation template body.

- Use the outputs.tf file to output the following:

    - KKE_stack_name: CloudFormation stack name

Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.

---

# Solution:

- `main.tf`:

```tf
resource "aws_cloudformation_stack" "kke_stack" {
  name = "xfusion-dynamodb-stack"

  template_body = local.cf_template_body

  lifecycle {
    ignore_changes = [parameters]
  }
}
```

- `locals.tf` is already ade available, you parametrize the 'TableName' filed:

```tf
locals {
  cf_template_body = <<JSON
{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Resources": {
    "MyDynamoDBTable": {
      "Type": "AWS::DynamoDB::Table",
      "Properties": {
        "TableName": "${var.KKE_DYNAMODB_TABLE_NAME}",
        "AttributeDefinitions": [
          {
            "AttributeName": "ID",
            "AttributeType": "S"
          }
        ],
        "KeySchema": [
          {
            "AttributeName": "ID",
            "KeyType": "HASH"
          }
        ],
        "ProvisionedThroughput": {
          "ReadCapacityUnits": 5,
          "WriteCapacityUnits": 5
        }
      }
    }
  }
}
JSON
}
```

- `variables.tf`:

```tf
variable "KKE_DYNAMODB_TABLE_NAME" {
  default = "xfusion-cf-dynamodb-table"
}
```

- `outputs.tf`:

```tf
output "KKE_stack_name" {
  description = "CloudFormation stack name"
  value       = aws_cloudformation_stack.kke_stack.name
}
```
