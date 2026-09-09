# Prevent S3 Bucket Deletion via Terraform

To ensure secure and accidental-deletion-proof storage, the DevOps team must configure an S3 bucket using Terraform with strict lifecycle protections. The goal is to create a bucket that is dynamically named and protected from being destroyed by mistake. Please complete the following tasks:

Create an S3 bucket named devops-s3-12564.

- Apply the prevent_destroy lifecycle rule to protect the bucket.

- Create the main.tf file (do not create a separate .tf file) to provision a s3 bucket with prevent_destroy lifecycle rule.

- Use the variables.tf file with the following:

    - KKE_BUCKET_NAME: name of the bucket.

- Use the terraform.tfvars file to input the name of the bucket.

- Use the outputs.tffile with the following:

- s3_bucket_name: name of the created bucket.

Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.


---

- `main.tf`:

```tf
resource "aws_s3_bucket" "kke_bucket" {
  bucket = var.KKE_BUCKET_NAME

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = var.KKE_BUCKET_NAME
  }
}
```

- `variables.tf`:

```tf
variable "KKE_BUCKET_NAME" {
  type = string
}
```


- `terraform.tfvars`:

```tf
KKE_BUCKET_NAME = "devops-s3-12564"
```


- `outputs.tf`:

```tf
output "s3_bucket_name" {
  description = "name of the created bucket"
  value       = var.KKE_BUCKET_NAME
}
```
