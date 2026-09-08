# Provision IAM User with Terraform


The Nautilus DevOps team is experimenting with Terraform provisioners. Your task is to create an IAM user and use a local-exec provisioner to log a confirmation message.

- Create an IAM user named iamuser_ravi.

- Use a local-exec provisioner with the IAM user resource to log the message KKE iamuser_ravi has been created successfully! to a file called KKE_user_created.log under home/bob/terraform.

- Create the main.tf file (do not create a separate .tf file) to provision an IAM user.

- Use variables.tf file with the following:

    - KKE_USER_NAME: name of the IAM user.

- Use terraform.tfvars to input the name of the IAM user.

- Use outputs.tf file with the following:

    - kke_iam_user_name: name of the IAM user.

Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.

---

# Solution:

- `main.tf`:

```tf
resource "aws_iam_user" "kke_user" {
  name = var.KKE_USER_NAME

  provisioner "local-exec" {
    command = "echo 'KKE ${self.name} has been created successfully!' > /home/bob/terraform/KKE_user_created.log"
  }

  tags = {
    Name = var.KKE_USER_NAME
  }
}
```


- `variables.tf`:

```tf
variable "KKE_USER_NAME" {
  type = string
}
```

- `terraform.tfvars`:

```tf
KKE_USER_NAME = "iamuser_ravi"
```


- `outputs.tf`:

```tf
output "kke_iam_user_name" {
  description = " name of the IAM user"
  value       = var.KKE_USER_NAME
}
```

- Confirm if the file is created and the contents match with t he requriements with 
```
cat ./KKE_user_created.log
`
