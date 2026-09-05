# Enable S3 Versioning Using Terraform

resource "aws_s3_bucket" "s3_ran_bucket" {
  bucket = "datacenter-s3-16491"
  acl    = "private"

  tags = {
    Name = "datacenter-s3-16491"
  }
}

# Add this bucket_versioning block
resource "aws_s3_bucket_versioning" "datacenter_s3_versioning" {
  bucket = aws_s3_bucket.s3_ran_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
