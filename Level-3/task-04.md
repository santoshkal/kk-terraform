# Streaming Secure Data with Kinesis, STS, and S3 Integration Using Terraform

The Nautilus DevOps team is working on a secure cloud-native architecture using Terraform. As part of this, they need to provision streaming and storage infrastructure using only the allowed AWS services supported by LocalStack.

Your task as a DevOps engineer is to complete the following:

- Create a Kinesis Stream: Provision a stream named nautilus-dev-stream with 1 shard and a 24-hour retention policy.

- Create an S3 Bucket: Create a bucket named nautilus-dev-597539053.

- Use STS for Identity Check: Retrieve and print the current AWS Account ID using aws_caller_identity.

- Ensure that the resources kinesis stream and s3 bucket are tagged with following:

    - Environment : dev (both the resources)

    - Purpose : Stream ingestion (Kinesis Stream)

    - Owner : nautilus (S3-bucket)

- Add local-exec provisioners to output the creation messages and save them under the /home/bob/terraform directory. Specifically:

- When creating the Kinesis stream, write the following message to a file named kinesis_creation.log:

    `"Kinesis Stream nautilus-dev-stream created"`

- When creating the S3 bucket, write the message to a file named s3_creation.log:

    `"S3 Bucket nautilus-dev-597539053 created"`

- When retrieving the STS caller identity, write the following message to a file named account_identity.log:

    `"Logged in as account ID:<AWS account ID>"`

- Create main.tf file (do not create a separate .tf file) to provision the kinesis stream, s3-bucket and retrieve the Current AWS Account ID.

- Use variables.tf file with the following variables:

    - KKE_ENVIRONMENT: dev
    - KKE_KINESIS_STREAM_NAME: Name of the Kinesis Stream (non-empty)
    - KKE_S3_BUCKET_NAME: Name of the S3 bucket.

- Use terraform.tfvars to input the variable values.

- Use outputs.tf to output the following:

    - kke_caller_identity_account_id: current AWS account ID.
    - kke_kinesis_stream_name: name of the stream created.
    - kke_s3_bucket_name: name of the bucket created.

Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration. You may need to run terraform apply multiple times.


---

# Solution:

- `main.tf`:

```tf
resource "aws_kinesis_stream" "kke_stream" {
  name             = var.KKE_KINESIS_STREAM_NAME
  shard_count      = 1
  retention_period = 24

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
  provisioner "local-exec" {
    command = "echo 'Kinesis Stream ${self.name} created' > /home/bob/terraform/kinesis_creation.log"
  }
  tags = {
    Environment = var.KKE_ENVIRONMENT
    Purpose     = "Stream ingestion"
  }
}

resource "aws_s3_bucket" "kke_bucket" {
  bucket = var.KKE_S3_BUCKET_NAME

  provisioner "local-exec" {
    command = "echo 'S3 Bucket ${self.bucket} created' > /home/bob/terraform/s3_creation.log"
  }
  tags = {
    Environment = var.KKE_ENVIRONMENT
    Owner       = "xfusion"
  }
}
data "aws_caller_identity" "current" {}

resource "terraform_data" "account_identity" {
  provisioner "local-exec" {
    command = "echo 'Logged in as account ID: ${data.aws_caller_identity.current.account_id}' > /home/bob/terraform/account_identity.log"
  }
}
```

- `variables.tf`:
```tf
variable "KKE_ENVIRONMENT" {
  type = string

}

variable "KKE_KINESIS_STREAM_NAME" {
  type = string
}

variable "KKE_S3_BUCKET_NAME" {
  type = string
}
```


- `terraform.tfvars`:

```tf
KKE_KINESIS_STREAM_NAME = "nautilus-dev-stream"
KKE_S3_BUCKET_NAME      = "nautilus-dev-597539053"
KKE_ENVIRONMENT         = "dev"
```

- `outputs.tf`: 

```tf
output "kke_caller_identity_account_id" {
  description = "current AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "kke_kinesis_stream_name" {
  description = "name of the stream created"
  value       = aws_kinesis_stream.kke_stream.name
}

output "kke_s3_bucket_name" {
  description = "name of the bucket created"
  value       = aws_s3_bucket.kke_bucket.bucket
}
```


## Note:
Before submitting the task, ensure that `terraform plan` returns No changes. *Your infrastructure matches the configuration*. You may need to run terraform apply multiple times.
