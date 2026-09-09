# Configure CloudWatch to Trigger SNS Alerts Using Terraform

The Nautilus DevOps team is expanding their AWS infrastructure and requires the setup of a CloudWatch alarm and SNS integration for monitoring EC2 instances. The team needs to configure an SNS topic for CloudWatch to publish notifications when an EC2 instance’s CPU utilization exceeds 80%. The alarm should trigger whenever the CPU utilization is greater than 80% and notify the SNS topic to alert the team.

- Create an SNS topic named nautilus-sns-topic.

- Create a CloudWatch alarm named nautilus-cpu-alarm to monitor EC2 CPU utilization with the following conditions:

    - Metric: CPUUtilization
    - Threshold: 80%
    - Actions enabled
    - Alarm actions should be triggered to the SNS topic.

- Ensure that the SNS topic receives notifications from the CloudWatch alarm when it is triggered.

- Update the main.tf file (do not create a different .tf file) to create SNS Topic and Cloudwatch Alarm.

- Create an outputs.tf file to output the following values:

    - KKE_sns_topic_name for the SNS topic name.
    - KKE_cloudwatch_alarm_name for the CloudWatch alarm name.


Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.

---

# Solution:

- `main.tf`:

```tf
# Add your code below
resource "aws_sns_topic" "kke_topic" {
  name = "nautilus-sns-topic"
}


resource "aws_cloudwatch_metric_alarm" "kke_alarm" {
  alarm_name                = "nautilus-cpu-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.kke_topic.arn]
}
```


- `outputs.tf`:

```tf
output "KKE_sns_topic_name" {
  description = "SNS topic name"
  value       = aws_sns_topic.kke_topic.name
}

output "KKE_cloudwatch_alarm_name" {
  description = "CloudWatch alarm name"
  value       = aws_cloudwatch_metric_alarm.kke_alarm.alarm_name
}
```
