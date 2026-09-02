# Create SNS Topic Using Terraform

resource "aws_sns_topic" "xfusion" {
  name = "xfusion-notifications"
}
