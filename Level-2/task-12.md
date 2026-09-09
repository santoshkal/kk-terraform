# Integrate SNS with SQS for Messaging Using Terraform

The Nautilus DevOps team is implementing a messaging system in AWS. They want to create an SNS topic and an SQS queue. The team needs to subscribe the SQS queue to the SNS topic so that any messages sent to the SNS topic will be delivered to the SQS queue.

- Create an SNS topic named xfusion-sns-topic.

- Create an SQS queue named xfusion-sqs-queue.

- Subscribe the SQS queue to the SNS topic.

- Use the main.tf file (do not create a separate .tf file) to provision the SNS topic and SQS queue.

- Create the outputs.tf file, and use the following:

    - The ARN of the SNS topic using the output variable kke_sns_topic_arn.

    - The URL of the SQS queue using the output variable kke_sqs_queue_url.


Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.
---

# Solution:

- `main.tf`:

```tf
resource "aws_sns_topic" "kke_topic" {
  name = "xfusion-sns-topic"
}

resource "aws_sqs_queue" "kke_queue" {
  name = "xfusion-sqs-queue"

  tags = {
    Name = "xfusion-sqs-queue"
  }
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.kke_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.kke_queue.arn
}
```


- `outputs.tf`:

```tf
output "kke_sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.kke_topic.arn
}

output "kke_sqs_queue_url" {
  description = "URL of the SQS queue"
  value       = aws_sqs_queue.kke_queue.url
}
```

