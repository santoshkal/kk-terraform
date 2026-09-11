# Managing Terraform Workspaces for Environment Isolation Using Terraform

The DevOps team is tasked with provisioning multiple API Gateway REST APIs and corresponding CloudWatch Log Groups using the following Terraform features:

- Create two workspaces named dev and prod.

- Create API Gateways named dev-nautilus-api-1 and prod-nautilus-api-2.

- Create matching CloudWatch Log Groups named /aws/apigateway/dev-nautilus-api-1 and /aws/apigateway/prod-nautilus-api-2.

- Use the count meta-argument to create multiple API Gateway REST APIs and matching log groups.

- Leverage terraform workspaces to differentiate API Gateway names per environment.

- Use local-exec provisioner to write a confirmation message to a log file once each resource is created.(e.g., Created API Gateway dev-nautilus-api-2 in workspace dev).

- Create two different files apigateway.log and loggroups.log in /home/bob/terraform to log the creation of each resource in their respective files.

- Use a list variable KKE_API_NAMES to define API names (e.g., ["nautilus-api-1", "nautilus-api-2"]).

- Create main.tf file (do not create a separate .tf file) to provision the api gateway with matching log groups in different workspaces.

- Use variables.tf file with the following:

    - KKE_API_NAMES = Names of API Gateways to create.

- Use terraform.tfvars file to input the names of the API Gateways.

- Use outputs.tf file to output the following in the two different workspces ( devand prod).

    - kke_api_gateway_names= name of the api gateway created.
    - kke_log_group_names= name of the matching logroups created.

Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.


---

# Solution:

## Terraform workspace setup

```bash
terraform init

#Create dev workspace
terraform workspace new dev

# Create prod workspace
terraform workspace new prod

# Confirm workspaces
terraform workspace list

# Switch back to dev workspace
terraform workspace select dev
```

- `main.tf`:

```tf
locals {
  api_index = terraform.workspace 
}

resource "aws_api_gateway_rest_api" "kke_api" {
  count = 1

  name = "${terraform.workspace}-${var.KKE_API_NAMES[local.api_index]}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  provisioner "local-exec" {
    command = "echo 'Created API Gateway ${self.name} in workspace ${terraform.workspace}' >> /home/bob/terraform/apigateway.log"
  }
}

resource "aws_cloudwatch_log_group" "kke_log_group" {
  count = 1

  name = "/aws/apigateway/${aws_api_gateway_rest_api.kke_api[count.index].name}"

  provisioner "local-exec" {
    command = "echo 'Created Log Group ${self.name} in workspace ${terraform.workspace}' >> /home/bob/terraform/loggroups.log"
  }
}
```

- `variables.tf`:

```tf
variable "KKE_API_NAMES" {
  type = list(string)
}
```

- `terraform.tfvars`:

```tf
KKE_API_NAMES = [
  "nautilus-api-1",
  "nautilus-api-2"
]
```

- `outputs.tf`:

```tf
output "kke_api_gateway_names" {
  description = "Name of the API Gateway created"
  value       = aws_api_gateway_rest_api.kke_api[*].name
}

output "kke_log_group_names" {
  description = "Name of the matching CloudWatch Log Group created"
  value       = aws_cloudwatch_log_group.kke_log_group[*].name
}
```


## Now create resource from prod workspace

```bash
# Switch to prod workspace
terraform workspace select prod

# Apply config
terraform apply
```


## File contents:
```bash
bob@iac-server ~/terraform via 💠 dev ➜  cat apigateway.log 
Created API Gateway dev-devops-api-1 in workspace dev
Created API Gateway dev-devops-api-2 in workspace dev
Created API Gateway prod-devops-api-2 in workspace prod
Created API Gateway prod-devops-api-1 in workspace prod
```
```

```bash
bob@iac-server ~/terraform via 💠 dev ➜  cat loggroups.log 
Created Log Group /aws/apigateway/dev-devops-api-2 in workspace dev
Created Log Group /aws/apigateway/dev-devops-api-1 in workspace dev
Created Log Group /aws/apigateway/prod-devops-api-1 in workspace prod
Created Log Group /aws/apigateway/prod-devops-api-2 in workspace prod
```

