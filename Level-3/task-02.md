# Building a Real-Time Data Ingestion Pipeline with Kinesis Firehose Using Terraform


The DevOps team needs to create a data ingestion pipeline using AWS Kinesis Firehose to deliver streaming data into an S3 bucket. The Firehose delivery stream must assume an IAM role using STS, deliver data to an S3 bucket, and add a newline delimiter after each record. Buffering settings should be configured to deliver data either when the buffer reaches 5 MB or after 300 seconds, whichever comes first.

You are required to complete this task using Terraform.

Task Requirements:

- Create an S3 bucket named devops-stream-bucket-31613 using Terraform.

- Create an IAM role named firehose-sts-role and policy that allows Kinesis Firehose to put objects into the S3 bucket.

- The Firehose delivery stream must use the IAM role via STS assume role.

- Use depends_on in the Firehose resource to ensure it waits for the IAM role policy attachment.

- Create a Firehose delivery stream named devops-firehose-stream to deliver data to the S3 bucket.

- Configure buffering with size 5 MB and interval 300 seconds.

- Enable record processing by setting the Delimiter parameter to \n to append a newline after each record.

- Create main.tf file to create a S3 bucket,IAM role and Firehose delivery stream.

- Use variables.tf file with the following variables:

    - KKE_S3_BUCKET_NAME: name of the bucket.
    - KKE_FIREHOSE_STREAM_NAME: name of the firehose stream.
    - KKE_FIREHOSE_ROLE_NAME : name of the firehose role

- Use outputs.tf file to output the following:

    - kke_firehose_stream_name: name of the firehose stream created.
    - kke_s3_bucket_name: name of the bucket created.
    - kke_firehose_role_arn: arn of the created firehose role.

- Send test data to the Firehose stream and verify that each record in the S3 files ends with a newline character.


Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.


---

# Solution:

- `main.tf`:

```tf
resource "aws_s3_bucket" "kke_bucket" {
  bucket = var.KKE_S3_BUCKET_NAME
}

resource "aws_iam_role" "kke_role" {
  name = var.KKE_FIREHOSE_ROLE_NAME

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"

        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = var.KKE_FIREHOSE_ROLE_NAME
  }
}

resource "aws_iam_policy" "kke_policy" {
  name = "kke_firehose_policy"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:PutObject"
        ]

        Resource = "${aws_s3_bucket.kke_bucket.arn}/*"
      }
    ]
  })
}

# User iam_role_policy_attachment and not iam_policy_attachment
resource "aws_iam_role_policy_attachment" "kke_attach" {
  role      = aws_iam_role.kke_role.name
  policy_arn = aws_iam_policy.kke_policy.arn
}

resource "aws_kinesis_firehose_delivery_stream" "kke_s3_stream" {
  name        = var.KKE_FIREHOSE_STREAM_NAME
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.kke_role.arn
    bucket_arn = aws_s3_bucket.kke_bucket.arn

    buffering_size     = 5
    buffering_interval = 300

    processing_configuration {
      enabled = true

      processors {
        type = "RecordDeAggregation"

        parameters {
          parameter_name  = "Delimiter"
          parameter_value = "\n"
        }
      }

      processors {
        type = "AppendDelimiterToRecord"
      }
    }
  }

  # This depends_on is important requirement of the task
  depends_on = [
    aws_iam_role_policy_attachment.kke_attach
  ]
}
```

- `variables.tf`:

```tf
variable "KKE_S3_BUCKET_NAME" {
  type    = string
  default = "devops-stream-bucket-31613"
}

variable "KKE_FIREHOSE_STREAM_NAME" {
  type    = string
  default = "devops-firehose-stream"
}

variable "KKE_FIREHOSE_ROLE_NAME" {
  type    = string
  default = "firehose-sts-role"
}
```

- `outputs.tf`:

```tf
output "kke_firehose_stream_name" {
  description = "name of the firehose stream"
  value       = aws_kinesis_firehose_delivery_stream.kke_s3_stream.name
}
output "kke_s3_bucket_name" {
  description = "name of the S3 bucket"
  value       = aws_s3_bucket.kke_bucket.bucket
}

output "kke_firehose_role_arn" {
  description = "arn of the created firehose role"
  value       = aws_iam_role.kke_role.arn
}
```


- Error:

```
Firehose stream does not depend on IAM role policy attachment
```
