# Managing Multiple S3 Buckets with Fine-Grained Access Policies Using Terraform


The Nautilus DevOps team needs to set up three S3 buckets for different environments with backup and policy configurations. Follow the steps below:

Create three S3 buckets using for_each for environments: Dev, Staging, and Prod.

Name the buckets using the following naming convention:

    - devops-dev-bucket-871763902
    - devops-staging-bucket-871763902
    - devops-prod-bucket-871763902

- Add the following tags to each bucket with the corresponding values:

a.) For devops-dev-bucket-871763902:

    Name = devops-dev-bucket-871763902
    Environment = Dev
    Owner = Alice

b.) For devops-staging-bucket-871763902:

    Name = devops-staging-bucket-871763902
    Environment = Staging
    Owner = Bob
\
c.) For devops-prod-bucket-871763902:

    Environment = Prod
    Owner = Carol

- For the staging and prod buckets, set Backup = true and add a lifecycle rule with ID MoveToGlacier to transition objects to Glacier after 30 days.

- Use the lifecycle block with ignore_changes to protect the tags.

- Create a bucket policy that allows public read access to all objects in the bucket.

- Use depends_on to ensure the policy is only applied after the bucket has been created.

- Implement the entire configuration in a single main.tf file (do not create a separate .tf file) to provision multiple S3 buckets with the specified configurations.

- Use variables.tf with the following variable:

    KKE_ENV_TAGS. KKE_ENV_TAGS is a map that holds environment-specific metadata such as bucket name, owner, and backup flag.

- Use outputs.tf file to output the following:

    kke_bucket_names: output the names of the bucket created.

Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.

---

# Solution:

- `main.tf`:

```tf
resource "aws_s3_bucket" "example" {
  for_each = var.KKE_ENV_TAGS

  bucket = each.value.bucket_name

  tags = {
    Name        = each.value.bucket_name
    Environment = title(each.key)
    Owner       = each.value.owner
  }

  # Protect tags from being changed by Terraform
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "example" {
  for_each = {
    for env, config in var.KKE_ENV_TAGS :
    env => config if config.backup
  }

  bucket = aws_s3_bucket.example[each.key].bucket

  rule {
    id     = "MoveToGlacier"
    status = "Enabled"
    prefix = ""

    transition {
      days          = 30
      storage_class = "GLACIER"
    }
  }
}

resource "aws_s3_bucket_policy" "example" {
  for_each = var.KKE_ENV_TAGS

  bucket = aws_s3_bucket.example[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "PublicReadGetObject"
        Effect = "Allow"

        Principal = "*"

        Action = "s3:GetObject"

        Resource = "${aws_s3_bucket.example[each.key].arn}/*"
      }
    ]
  })

  depends_on = [
    aws_s3_bucket.example
  ]
}
```

- `variables.tf`:

```tf
variable "KKE_ENV_TAGS" {
  type = map(object({
    bucket_name = string
    owner       = string
    backup      = bool
  }))
}
```

- `outputs.tf`:


```tf
output "kke_bucket_names" {
  description = "Names of the S3 buckets created"
  value       = [for bucket in aws_s3_bucket.example : bucket.bucket]
}
```
