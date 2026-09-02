# Create Private S3 Bucket Using Terraform

resource "aws_s3_bucket" "xfusion-s3" {
  bucket = "xfusion-s3-24274"

  tags = {
    Name = "xfusion-s3-24274"
  }
}


resource "aws_s3_bucket_public_access_block" "xfusion-s3" {
  bucket = aws_s3_bucket.xfusion-s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
