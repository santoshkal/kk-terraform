# Task 32
## Copy Data to S3 Using Terraform

The Nautilus DevOps team is presently immersed in data migrations, transferring data from on-premise storage systems to AWS S3 buckets. They have recently received some data that they intend to copy to one of the S3 buckets.

S3 bucket named devops-cp-23249 already exists. Copy the file /tmp/devops.txt to s3 bucket devops-cp-23249 using Terraform. The Terraform working directory is /home/bob/terraform. Update the main.tf file (do not create a separate .tf file) to accomplish this task.

Note: Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

---

# Solution:

```tf
resource "aws_s3_bucket" "my_bucket" {
  bucket = "devops-cp-23249"
  acl    = "private"

  tags = {
    Name = "devops-cp-23249"
  }
}

# Add this block
resource "aws_s3_object" "s3-copy" {
  bucket = "devops-cp-23249"
  key    = "devops"
  source = "/tmp/devops.txt"
}
```

Run terraform commands `init`, `plan`, and `apply`
