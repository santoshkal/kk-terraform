# Implement S3 Lifecycle Management Policy Using Terraform

The Nautilus DevOps team is implementing lifecycle policies to manage object storage efficiently in AWS. They want to create an S3 bucket with a specific lifecycle rule that transitions objects to infrequent access (IA) storage after 30 days and deletes them after 365 days.

- Create an S3 bucket named xfusion-lifecycle-31617.

- Enable the S3 Versioning on the bucket.

- Add a lifecycle rule named xfusion-lifecycle-rule with:

- Transition to STANDARD_IA storage class after 30 days.

- Expiration of objects after 365 days.

- Use the main.tf file (do not create a separate .tf file) to provision the S3 bucket.

- Use the variable name KKE_bucket_name in the outputs.tf file to output the created bucket name.


Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.

---

# Solution:

- `main.tf`:

```tf
resource "aws_s3_bucket" "kke_bucket" {
  bucket = "xfusion-lifecycle-31617"

  tags = {
    Name = "xfusion-lifecycle-31617"
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.kke_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "example" {
  bucket = aws_s3_bucket.kke_bucket.bucket

  rule {
    id = "xfusion-lifecycle-rule"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    expiration {
      days = 365
    }


    # ... other transition/expiration actions ...

    status = "Enabled"
  }
}
```

- `outputs.tf`:

```tf
output "KKE_bucket_name" {
  description = "bucket name"
  value       = aws_s3_bucket.kke_bucket.bucket
}
```



