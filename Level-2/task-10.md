# Grant EC2 Access to S3 Bucket Using Terraform

The Nautilus DevOps team wants to set up EC2 instances that securely upload application logs to S3 using IAM roles.

- Create an EC2 instance named datacenter-ec2 that can access an S3 bucket securely.

- Create an S3 bucket named datacenter-logs-17348.

- Create an IAM role named datacenter-role with a policy named datacenter-access-policy allowing S3 PutObject on the above bucket.

- Attach the IAM role to the EC2 instance to allow it to upload logs to the bucket.

- Create the main.tf (do not create a separate .tf file) to provision the EC2, s3, role and policy.

- Create the variables.tffile to declare the following:

    - KKE_BUCKET_NAME: name of the bucket.
    - KKE_POLICY_NAME: name of the policy.
    - KKE_ROLE_NAME: name of the role.

- Create the terraform.tfvars file to assign values to variables.

- Create a data.tf file to fetch the latest Amazon Linux 2 AMI.


Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.

---

# Solution:

- `main.tf`:

```tf
# S3 bucket
resource "aws_s3_bucket" "datacenter_logs" {
  bucket = var.KKE_BUCKET_NAME
}

# IAM role
resource "aws_iam_role" "datacenter_role" {
  name = var.KKE_ROLE_NAME

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM policy allowing PutObject to the S3 bucket
resource "aws_iam_policy" "datacenter_access_policy" {
  name = var.KKE_POLICY_NAME

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:PutObject"
        ]

        Resource = "${aws_s3_bucket.datacenter_logs.arn}/*"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "datacenter_access" {
  role       = aws_iam_role.datacenter_role.name
  policy_arn = aws_iam_policy.datacenter_access_policy.arn
}

# We need to create instance_profile, so that we can attach a role to EC2
# Instance profile containing the IAM role

resource "aws_iam_instance_profile" "datacenter_profile" {
  name = "datacenter-instance-profile"
  role = aws_iam_role.datacenter_role.name
}

# EC2 instance
resource "aws_instance" "datacenter_ec2" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.datacenter_profile.name

  tags = {
    Name = "datacenter-ec2"
  }
}
```

- `data.tf`:

```tf
data "aws_ssm_parameter" "amazon_linux_2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "image-id"
    values = [data.aws_ssm_parameter.amazon_linux_2.value]
  }

  owners = ["amazon"]
}
```


- `variables.tf`:

```tf
variable "KKE_BUCKET_NAME" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "KKE_POLICY_NAME" {
  description = "Name of the IAM policy"
  type        = string
}

variable "KKE_ROLE_NAME" {
  description = "Name of the IAM role"
  type        = string
}
```

- `terraform.tfvars`:

```tf
KKE_BUCKET_NAME = "datacenter-logs-17348"
KKE_POLICY_NAME = "datacenter-access-policy"
KKE_ROLE_NAME   = "datacenter-role"
```
