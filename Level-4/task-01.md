# Alerting in CI/CD Pipelines Using Terraform

The Nautilus DevOps team has been tasked to build a real-time data pipeline on AWS. The pipeline must collect streaming data, stage it in S3, monitor delivery failures, and alert via email. Your task is to implement this end-to-end using Terraform.

Pipeline Requirements:

1.) Kinesis Firehose:

Create a delivery stream named xfusion-firehose.
It should deliver data to an S3 bucket as a staging area.

2.) S3 Bucket:

Create a bucket named xfusion-staging-533742183 (value to come from variables).
Set private ACL and allow Firehose to write objects into it.

3.) IAM Role and Policy:

Create a role xfusion-firehose-role and a policy xfusion-firehose-policy with least privilege to allow Firehose to write to the staging bucket.

4.) CloudWatch Alarm:

Create a cloudwatch Alarm named xfusion-firehose-failures.
Monitor the Firehose delivery failures metric (DeliveryToS3.Failures) and trigger when failures occur.

5.) SNS Topic:

Create a topic xfusion-alert-topic and link the CloudWatch alarm to it.

6.) SES Email Identity:

Create an SES email identity named xfusion@example.comand verify an SES email identity using an email address provided in the variables.

7.) SNS Subscription:

Subscribe the verified SES email identity to the SNS topic to receive notifications.

8.) Use main.tf file to define all AWS resources and to ensure a clean and modular setup.

9.) Use variables.tf file with the following variables:

    KKE_STAGING_BUCKET_NAME: Name of the S3 bucket for staging data.
    KKE_FIREHOSE_ROLE_NAME: Name of the IAM role for the Firehose delivery stream.
    KKE_FIREHOSE_POLICY_NAME: Name of the IAM policy for the Firehose delivery stream.
    KKE_FIREHOSE_NAME: Name of the Kinesis Firehose delivery stream.
    KKE_SNS_TOPIC_NAME: Name of the SNS topic for alerts.
    KKE_CLOUDWATCH_ALARM_NAME: Name of the CloudWatch alarm to monitor Firehose delivery failures.
    KKE_ALERT_EMAIL: Email address to receive SNS alerts through SES.

10.) Use terraform.tfvarsto input the value of the variables used in the variables.tf.

11.) Use outputs.tf file to output the following:

    kke_staging_bucket_name: Name of the bucket used.
    kke_firehose_name: Name of the firehose delivery stream used.
    kke_sns_topic_name: Name of the sns topic used.
    kke_cloudwatch_alarm_name: Name of the cloudwatch used.
    kke_ses_identity: Name of the ses identity used.

Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns `No changes. Your infrastructure matches the configuration

---

# Solution:

- `main.tf`:

```tf
resource "aws_s3_bucket" "kke_s3" {
  bucket = var.KKE_STAGING_BUCKET_NAME

  tags = {
    Name        = var.KKE_STAGING_BUCKET_NAME
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "kke_s3" {
  bucket = aws_s3_bucket.kke_s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_iam_role" "kke_firehose_role" {
  name = var.KKE_FIREHOSE_ROLE_NAME

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "firehose.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = var.KKE_FIREHOSE_ROLE_NAME
  }
}

resource "aws_iam_policy" "kke_firehose_policy" {
  name = var.KKE_FIREHOSE_POLICY_NAME

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads"
        ]

        Resource = aws_s3_bucket.kke_s3.arn
      },
      {
        Effect = "Allow"

        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]

        Resource = "${aws_s3_bucket.kke_s3.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "kke_firehose_policy_attachment" {
  role       = aws_iam_role.kke_firehose_role.name
  policy_arn = aws_iam_policy.kke_firehose_policy.arn
}


resource "aws_kinesis_firehose_delivery_stream" "kke_s3_stream" {
  name        = var.KKE_FIREHOSE_NAME
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.kke_firehose_role.arn
    bucket_arn = aws_s3_bucket.kke_s3.arn

    buffering_size     = 5
    buffering_interval = 300

    processing_configuration {
      enabled = true
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.kke_firehose_policy_attachment
  ]
}


resource "aws_cloudwatch_metric_alarm" "kke_alarm" {
  alarm_name = var.KKE_CLOUDWATCH_ALARM_NAME

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1

  metric_name = "DeliveryToS3.Failures"
  namespace   = "AWS/Firehose"

  period    = 60
  statistic = "Sum"
  threshold = 1

  alarm_description = "Alarm when Kinesis Firehose delivery to S3 fails"

  dimensions = {
    DeliveryStreamName = aws_kinesis_firehose_delivery_stream.kke_s3_stream.name
  }

  alarm_actions = [
    aws_sns_topic.kke_topic.arn
  ]

  insufficient_data_actions = []

  depends_on = [
    aws_sns_topic.kke_topic
  ]
}

resource "aws_sns_topic" "kke_topic" {
  name = var.KKE_SNS_TOPIC_NAME
}

resource "aws_ses_email_identity" "kke_email" {
  email = var.KKE_ALERT_EMAIL
}

resource "aws_sns_topic_subscription" "kke_email_subscription" {
  topic_arn = aws_sns_topic.kke_topic.arn

  protocol = "email"

  endpoint = var.KKE_ALERT_EMAIL

  depends_on = [
    aws_ses_email_identity.kke_email
  ]
}
```

- `variables.tf`:

```tf
variable "KKE_STAGING_BUCKET_NAME" {
  type = string
}

variable "KKE_FIREHOSE_ROLE_NAME" {
  type = string
}

variable "KKE_FIREHOSE_POLICY_NAME" {
  type = string
}
variable "KKE_FIREHOSE_NAME" {
  type = string
}
variable "KKE_SNS_TOPIC_NAME" {
  type = string
}
variable "KKE_ALERT_EMAIL" {
  type = string
}
variable "KKE_CLOUDWATCH_ALARM_NAME" {
  type = string
}
```

- `terraform.tfvars`:

```tf
KKE_STAGING_BUCKET_NAME   = "xfusion-staging-533742183"
KKE_FIREHOSE_ROLE_NAME    = "xfusion-firehose-role"
KKE_FIREHOSE_POLICY_NAME  = "xfusion-firehose-policy"
KKE_FIREHOSE_NAME         = "xfusion-firehose"
KKE_SNS_TOPIC_NAME        = "xfusion-alert-topic"
KKE_CLOUDWATCH_ALARM_NAME = "xfusion-firehose-failures"
KKE_ALERT_EMAIL           = "xfusion@example.com"
```

- `outputs.tf`:

```tf
output "kke_staging_bucket_name" {
  description = "Name of the bucket used"
  value       = aws_s3_bucket.kke_s3.bucket
}

output "kke_firehose_name" {
  description = "Name of the firehose delivery stream used"
  value       = aws_kinesis_firehose_delivery_stream.kke_s3_stream.name
}

output "kke_sns_topic_name" {
  description = "Name of the sns topic used"
  value       = aws_sns_topic.kke_topic.name
}

output "kke_cloudwatch_alarm_name" {
  description = "Name of the cloudwatch used"
  value       = aws_cloudwatch_metric_alarm.kke_alarm.alarm_name
}

output "kke_ses_identity" {
  description = "Name of the ses identity used"
  value       = aws_ses_email_identity.kke_email.email
}
```
