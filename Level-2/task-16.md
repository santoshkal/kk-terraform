# Send Notifications from IAM Events to SNS Using Terraform

To enable secure inter-service communication, the DevOps team needs to configure access to an SNS topic using IAM roles and policies. The objective is to allow EC2 instances to publish messages to the topic using proper permissions and role assumptions. Please complete the following tasks:

- Create an SNS topic named datacenter-sns-topic.

- Create an IAM role named datacenter-sns-role with EC2 as the trusted entity.

- Attach an IAM policy named datacenter-sns-policy that grants permission to publish messages to the SNS topic.

- Use the main.tf file (do not create a separate .tf file) to provision the sns-topic, role and policy.

- Create the locals.tfwith the following names:

    - KKE_SNS_TOPIC_NAME:name of the sns topic created.
    - KKE_ROLE_NAME: name of the role created.
    - KKE_POLICY_NAME: name of the policy created.

- Create the outputs.tf file to the output the following:

- The name of the SNS topic using the output variable kke_sns_topic_name.

- The name of the role using the output variable kke_role_name.

- The name of the policy using the output variable kke_policy_name.


Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.


---

# Solution:

- `main.tf`:

```tf
# Add your code below


resource "aws_sns_topic" "kke_topic" {
  name = local.KKE_SNS_TOPIC_NAME
}

resource "aws_iam_role" "kke_role" {
  name = local.KKE_ROLE_NAME

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
    Name = local.KKE_ROLE_NAME
  }
}

resource "aws_iam_policy" "kke_policy" {
  name = local.KKE_POLICY_NAME

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sns:Publish*",
        ]
        Effect   = "Allow"
        Resource = aws_sns_topic.kke_topic.arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "kke-attach" {
  role       = aws_iam_role.kke_role.name
  policy_arn = aws_iam_policy.kke_policy.arn
}
```

- `locals.tf`:

```tf
locals {
  KKE_SNS_TOPIC_NAME = "datacenter-sns-topic"
  KKE_ROLE_NAME      = "datacenter-sns-role"
  KKE_POLICY_NAME    = "datacenter-sns-policy"
}
```

- `outputs.tf`:

```tf
output "kke_sns_topic_name" {
  description = "name of the SNS topic "
  value       = aws_sns_topic.kke_topic.name
}

output "kke_role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.kke_role.name
}

output "kke_policy_name" {
  description = "Name of the IAM policy"
  value       = aws_iam_policy.kke_policy.name
}
```
