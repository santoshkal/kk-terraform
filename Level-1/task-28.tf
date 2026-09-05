# Delete Backup from S3 Using Terraform

# Copy t he contents to local dir

resource "terraform_data" "s3_backup" {
  provisioner "local-exec" {
    command = "aws s3 cp s3://datacenter-bck-4253 /opt/s3-backup/ --recursive"
  }
}

# Delete Bucket
# aws s3 rb s3://datacenter-bck-4253 --force
