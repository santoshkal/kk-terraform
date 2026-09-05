# User Variable Setup Using Terraform

The Nautilus DevOps team is automating IAM user creation using Terraform for better identity management.

For this task, create an AWS IAM User using Terraform with the following requirements:

The IAM User name iamuser_james should be stored in a variable named KKE_user.
Note:

1. The configuration values should be stored in a variables.tf file.

2. The Terraform script should be structured with a main.tf file referencing variables.tf.
The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

---

# Solution:

- `variables.tf`

```tf
variable "KKE_user" {
  type    = string
  default = "iamuser_james"
}
```

- `main.tf`

```tf
resource "aws_iam_user" "kke" {
  name = var.KKE_user

  tags = {
    tag-key = var.KKE_user
  }
}
```
