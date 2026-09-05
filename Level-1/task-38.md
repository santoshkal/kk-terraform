# Policy Variable Setup Using Terraform





---

# Solution

- `variables.tf`

```tf
variable "KKE_iampolicy" {
  type    = string
  default = "iampolicy_anita"
}
```


- `main.tf`

```tf
resource "aws_iam_policy" "kk_policy" {
  name        = var.KKE_iampolicy
  path        = "/"
  description = "My test policy"

  # required argument
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

  tags = {
    Name = var.KKE_iampolicy
  }
}
```
