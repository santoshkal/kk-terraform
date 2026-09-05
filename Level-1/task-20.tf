# CloudWatch Setup Using Terraform

resource "aws_cloudwatch_log_group" "xfusion-log" {
  name = "xfusion-log-group"

  tags = {
    Name = "xfusion-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "xfusion-log-stream" {
  name           = "xfusion-log-stream"
  log_group_name = aws_cloudwatch_log_group.xfusion-log.name
}
