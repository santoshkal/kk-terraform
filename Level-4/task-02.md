# Implementing Local Variables Using Terraform

The DevOps team is tasked with designing and implementing a production‑grade, event‑driven infrastructure entirely using Terraform. This initiative is part of our internal platform engineering efforts to standardize infrastructure as code (IaC) practices across the organization.

Task Requirements:

- Use a locals block in your Terraform configuration to define the following:

    project name ( nautilus).

    environment (dev),

- A common name prefix by combining the project name and environment ( nautilus-dev).

- A map of default tags ( Project, Environment, Owner, and Team).

- Then, reference these locals values across all resources in your configuration to ensure consistent naming and consistent tagging.

- Create a SNS topic named project name-environment-topic.

- Create a SQS queue named project name-environment-queue and subscribe it to the SNS topic.

- Use depends_on to ensure the SNS topic is created before subscription.

- Create a DynamoDB table named project name-environment-events with primary key event_id (HASH key) and provisioned throughput of 5 read capacity units and 5 write capacity units.

- Create an IAM Role named project name-environment-role with a `dynamic inline policy allowing:

    sqs:ReceiveMessage
    dynamodb:PutItem
    sns:Publish

- Use validation blocks invariables.tf to:

    - Restrict allowed AWS regions to only us-east-1 (with error message)

    - Ensure the SNS queue depth threshold is between 1 and 1000 (with the error message).

- Use main.tf file to organize all AWS resources in a clean, modular, and easily maintainable Terraform configuration.

- Create a CloudWatch alarm named project name-environment-alarm for the SQS queue when it contains more than 50 messages (threshold configurable).

- Use variables.tf file with the following variables:

    - KKE_AWS_REGION:aws region used.
    - KKE_QUEUE_DEPTH_THRESHOLD:CloudWatch alarm threshold for queue depth.(default=50).
    - KKE_IAM_ACTIONS:IAM actions to allow in dynamic policy.

- Use outputs.tf file to output the following:

    - kke_cloudwatch_alarm_name:name of the alarm created.
    - kke_dynamodb_table_name:name of the table created.
    - kke_iam_role_arn: arn of the role created.
    - kke_sns_topic_arn: arn of the sns-topic created.
    - kke_sqs_queue_url: url of the sqs-queue created.

Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Use locals for the project name, environment, prefix, and tags so that, for example, if you create an SNS topic, its name (project-environment-topic) and all other resource names and tags stay consistent and easy to manage.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.

---
# Solution:

- `main.tf`:

```tf
locals {
  project     = "nautilus"
  environment = "dev"

  name_prefix = "${local.project}-${local.environment}"

  default_tags = {
    Project     = local.project
    Environment = local.environment
    Owner       = "nautilus"
    Team        = "devops"
  }
}

resource "aws_sns_topic" "kke_topic" {
  name = "${local.name_prefix}-topic"

  tags = local.default_tags
}

resource "aws_sqs_queue" "kke_queue" {
  name = "${local.name_prefix}-queue"

  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

  tags = local.default_tags
}

resource "aws_sns_topic_subscription" "kke_topic_subscription" {
  topic_arn = aws_sns_topic.kke_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.kke_queue.arn

  depends_on = [aws_sns_topic.kke_topic]
}

resource "aws_dynamodb_table" "kke_table" {
  name           = "${local.name_prefix}-events"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "event_id"

  attribute {
    name = "event_id"
    type = "S"
  }
  tags = local.default_tags
}

resource "aws_iam_role" "kke_role" {
  name = "${local.name_prefix}-role"

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

  inline_policy {
    name = "${local.name_prefix}-policy"

    policy = jsonencode({
      Version = "2012-10-17"

      Statement = [
        for action in var.KKE_IAM_ACTIONS : {
          Effect   = "Allow"
          Action   = action
          Resource = "*"
        }
      ]
    })
  }

  tags = local.default_tags
}

resource "aws_cloudwatch_metric_alarm" "kke_alarm" {
  alarm_name          = "${local.name_prefix}-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2

  metric_name = "ApproximateNumberOfMessagesVisible"
  namespace   = "AWS/SQS"

  period    = 120
  statistic = "Average"

  threshold = var.KKE_QUEUE_DEPTH_THRESHOLD

  dimensions = {
    QueueName = aws_sqs_queue.kke_queue.name
  }

  alarm_description = "Monitors SQS queue depth"

  insufficient_data_actions = []

  tags = local.default_tags
}
```


- `variables.tf`:

```tf
variable "KKE_AWS_REGION" {
  description = "AWS region used."

  type    = string
  default = "us-east-1"

  validation {
    condition     = var.KKE_AWS_REGION == "us-east-1"
    error_message = "Only us-east-1 is allowed."
  }
}

variable "KKE_QUEUE_DEPTH_THRESHOLD" {
  description = "CloudWatch alarm threshold for queue depth."

  type    = number
  default = 50

  validation {
    condition     = var.KKE_QUEUE_DEPTH_THRESHOLD >= 1 && var.KKE_QUEUE_DEPTH_THRESHOLD <= 1000
    error_message = "Queue depth threshold must be between 1 and 1000."
  }
}

variable "KKE_IAM_ACTIONS" {
  description = "IAM actions to allow in the dynamic policy."

  type = list(string)

  default = [
    "sqs:ReceiveMessage",
    "dynamodb:PutItem",
    "sns:Publish"
  ]
}
```


- `outputs.tf`:

```tf
output "kke_cloudwatch_alarm_name" {
  description = "name of the alarm created"
  value       = aws_cloudwatch_metric_alarm.kke_alarm.alarm_name
}

output "kke_dynamodb_table_name" {
  description = "name of the table created"
  value       = aws_dynamodb_table.kke_table.name
}

output "kke_iam_role_arn" {
  description = "arn of the role created"
  value       = aws_iam_role.kke_role.arn
}

output "kke_sns_topic_arn" {
  description = "arn of the sns-topic created"
  value       = aws_sns_topic.kke_topic.arn
}

output "kke_sqs_queue_url" {
  description = "url of the sqs-queue created"
  value       = aws_sqs_queue.kke_queue.url
}
```
