# Create Public S3 Bucket Using Terraform

resource "aws_s3_bucket" "xfusion-s3" {
  bucket = "xfusion-s3-14393"

  tags = {
    Name = "xfusion-s3-14393"
  }
}

resource "aws_s3_bucket_public_access_block" "xfusion-s3" {
  bucket = aws_s3_bucket.xfusion-s3.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
