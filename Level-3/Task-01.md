# Managing Scalable NoSQL Databases with Amazon DynamoDB Using Terraform


The Nautilus DevOps team is developing a simple 'To-Do' application using DynamoDB to store and manage tasks efficiently. The team needs to create a DynamoDB table to hold tasks, each identified by a unique task ID. Each task will have a description and a status, which indicates the progress of the task (e.g., 'completed' or 'in-progress').

Your task is to:

- Create a DynamoDB table named nautilus-tasks with a primary key called taskId (string).

- Insert the following tasks into the table:

- Task 1: taskId: 1, description: Learn DynamoDB, status: completed

- Task 2: taskId: 2, description: Build To-Do App, status: in-progress

- Verify that Task 1 has a status of completed and Task 2 has a status of in-progress.

- Create main.tf(do not create a separate .tf file) to provision a dynamo_db table and insert tasks.

- Create a variables.tf file with the following:

    - KKE_TABLE_NAME: name of the dynamo_db table.

- Use terraform.tfvars file to input the name of the dynamo_db table.

- Use outputs.tf file for the following:

    - kke_dynamodb_table_name: name of the dynamo_db table created.

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
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "taskId"

  attribute {
    name = "taskId"
    type = "S"
  }

  tags = {
    Name = var.KKE_TABLE_NAME
  }
}

resource "aws_dynamodb_table_item" "task_1" {
  table_name = aws_dynamodb_table.kke_dynamodb_table.name
  hash_key   = aws_dynamodb_table.kke_dynamodb_table.hash_key

  item = <<ITEM
{
  "taskId": {
    "S": "1"
  },
  "description": {
    "S": "Learn DynamoDB"
  },
  "status": {
    "S": "completed"
  }
}
ITEM
}

resource "aws_dynamodb_table_item" "task_2" {
  table_name = aws_dynamodb_table.kke_dynamodb_table.name
  hash_key   = aws_dynamodb_table.kke_dynamodb_table.hash_key

  item = <<ITEM
{
  "taskId": {
    "S": "2"
  },
  "description": {
    "S": "Build To-Do App"
  },
  "status": {
    "S": "in-progress"
  }
}
ITEM
}
```


- `variables.tf`:

```tf
variable "KKE_TABLE_NAME" {
  type = string
}
```

- `terraform.tfvars`:

```tf
KKE_TABLE_NAME = "nautilus-tasks"
```


- `outputs.tf`:

```tf
output "kke_dynamodb_table_name" {
  description = "name of the dynamo_db table"
  value       = aws_dynamodb_table.kke_dynamodb_table.name
}
```
