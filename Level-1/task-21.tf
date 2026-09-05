# CloudFormation Template Deployment Using Terraform

resource "aws_cloudformation_stack" "nautilus-stack" {
  name = "nautilus-stack"

  tags = {
    Name = "nautilus-stack"
  }
  template_body = jsonencode({
    Resources = {
      NautilusBucket = {
        Type = "AWS::S3::Bucket"
        Properties = {
          BucketName = "nautilus-bucket-16016"
          VersioningConfiguration = {
            Status = "Enabled"
          }
        }
      }
    }
  })
}
