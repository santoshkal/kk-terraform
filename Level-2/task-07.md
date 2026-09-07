# Stream Kinesis Data to CloudWatch Using Terraform

The monitoring team wants to improve observability into the streaming infrastructure. Your task is to implement a solution using Amazon Kinesis and CloudWatch. The team wants to ensure that if write throughput exceeds provisioned limits, an alert is triggered immediately.

As a member of the Nautilus DevOps Team, perform the following tasks using Terraform:

- Create a Kinesis Data Stream: Name the stream devops-kinesis-stream with a shard count of 1.

- Enable Monitoring: Enable shard-level metrics for the stream to track ingestion and throughput errors.

- Create a CloudWatch Alarm: Name the alarm devops-kinesis-alarm and monitor the WriteProvisionedThroughputExceeded metric. The alarm should trigger if the metric exceeds a threshold of 1.

- Ensure Alerting: Configure the CloudWatch alarm to detect write throughput issues exceeding provisioned limits.

- Create the main.tf file (do not create a separate .tf file) to provision the Kinesis stream, CloudWatch alarm, and ensure alerting.

- Create the outputs.tf file with the following variable names to output:

    - kke_kinesis_stream_name for the Kinesis stream name.

    - kke_kinesis_alarm_name for the CloudWatch alarm name.


Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.

---

# Solution:

- `main.tf`: 

```tf
resource "aws_kinesis_stream" "kk_kinesis_stream" {
  name        = "devops-kinesis-stream"
  shard_count = 1

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
    "WriteProvisionedThroughputExceeded",
  ]

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }

  tags = {
    Name = "devops-kinesis-stream"
  }
}

resource "aws_cloudwatch_metric_alarm" "devops-kinesis-alarm" {
  alarm_name        = "devops-kinesis-alarm"
  alarm_description = "Alarm for Kinesis write throughput exceeding provisioned limits"

  namespace           = "AWS/Kinesis"
  metric_name         = "WriteProvisionedThroughputExceeded"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    StreamName = aws_kinesis_stream.kk_kinesis_stream.name
  }

  insufficient_data_actions = []
}
```


- `outputs.tf`:

```tf
output "kke_kinesis_stream_name"{
    description = "Kinesis stream name"
    value = aws_kinesis_stream.kk_kinesis_stream.name
}

output "kke_kinesis_alarm_name"{
    description = "CloudWatch alarm name"
    value = aws_cloudwatch_metric_alarm.devops-kinesis-alarm.alarm_name
}
```
