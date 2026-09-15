# Managing Terraform Code with Symlinks

The DevOps team is building a Terraform-based AWS pipeline using strict modular design, symbolic links for configuration reuse, and a sequential resource flow

1) Create modules under modules/ named:

SNS Module: Create an SNS topic named devops-sns-topic.
SSM Module: Create an SSM Parameter named devops-param storing the ARN of the SNS topic from the SNS module. The SSM parameter should be of type String.
Step Functions Module: Create a Step Functions state machine named devops-stepfunction that retrieves the SNS topic ARN from the SSM Parameter. The Step Function should have an IAM role with a policy allowing ssm:GetParameter access to read the parameter.

2) Use symbolic links to reuse the root variables.tf file across all modules (no duplicated variable declarations inside module main.tf files). Ensure the symlink uses an absolute path.

3) Create a single main.tf in the root to orchestrate the module calls in sequence SNS → SSM → Step Functions. Pass the SNS ARN output from the SNS module to the SSM module, and the SSM parameter name output from the SSM module to the Step Functions module.

4) Use the depends_on feature so that SSM depends on SNS and StepFunctions depend on SSM.

5) Use variables.tf file with the following variable names:

KKE_SNS_TOPIC_NAME: name of the SNS topic.
KKE_SSM_PARAM_NAME: SSM parameter name.
KKE_STEP_FUNCTION_NAME: Step Function name.

6) Use terraform.tfvars file to input the values of the variables.

7) Use outputs.tf file with the following variables:

kke_sns_topic_name: name of the SNS topic created.
kke_ssm_parameter_name: name of the SSM parameter created.
kke_step_function_name: name of the Step Function created.

8) Additional implementation hints:

SNS Module: output both name and ARN of the topic.
SSM Module: set the value of the parameter to the SNS ARN received from the SNS module. Also, ensure the SSM parameter implementation creates a direct Terraform dependency on the SNS topic so that the dependency is visible in the Terraform graph.
Step Functions Module: create an IAM role and policy allowing ssm:GetParameter, then assign the role to the state machine. The Step Function can use a simple placeholder definition (e.g., Pass state) for this task.

Notes:

The Terraform working directory is /home/bob/terraform.
Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.
3.Ensure all modules use symlinks and avoid duplication.
Ensure that the variables.tf file in each module uses an absolute path for the symlink.
Before submitting the task, you must run terraform apply to create the infrastructure. Also, ensure that a subsequent terraform plan returns No changes. Your infrastructure matches the configuration. You may need to run terraform apply multiple times to resolve dependencies.


---
# Solution:

## Directory structure:

```bash
.
├── README.MD
├── main.tf
├── modules
│   ├── sns
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf -> /home/bob/terraform/variables.tf
│   ├── ssm
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf -> /home/bob/terraform/variables.tf
│   └── stepfunctions
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf -> /home/bob/terraform/variables.tf
├── outputs.tf
├── provider.tf
├── terraform.tfvars
└── variables.tf
```

## Create symlink to root variables.tf to all modules:

```bash
ln -s /home/bob/terraform/variables.tf modules/sns/variables.tf
ln -s /home/bob/terraform/variables.tf modules/ssm/variables.tf
ln -s /home/bob/terraform/variables.tf modules/stepfunctions/variables.tf
```

- `./main.tf`:

```tf
module "sns" {
  source = "./modules/sns"

  KKE_SNS_TOPIC_NAME     = var.KKE_SNS_TOPIC_NAME
  KKE_SSM_PARAM_NAME     = var.KKE_SSM_PARAM_NAME
  KKE_STEP_FUNCTION_NAME = var.KKE_STEP_FUNCTION_NAME
}

module "ssm" {
  source = "./modules/ssm"

  KKE_SNS_TOPIC_NAME     = var.KKE_SNS_TOPIC_NAME
  KKE_SSM_PARAM_NAME     = var.KKE_SSM_PARAM_NAME
  KKE_STEP_FUNCTION_NAME = var.KKE_STEP_FUNCTION_NAME


  depends_on = [
    module.sns
  ]
}

module "stepfunctions" {
  source = "./modules/stepfunctions"

  KKE_SNS_TOPIC_NAME     = var.KKE_SNS_TOPIC_NAME
  KKE_SSM_PARAM_NAME     = var.KKE_SSM_PARAM_NAME
  KKE_STEP_FUNCTION_NAME = var.KKE_STEP_FUNCTION_NAME

  depends_on = [
    module.ssm
  ]
}
```

- `./variables.tf`:

```tf
variable "KKE_SNS_TOPIC_NAME" {
  description = "Name of the SNS topic"
  type        = string
}

variable "KKE_SSM_PARAM_NAME" {
  description = "Name of the SSM parameter"
  type        = string
}

variable "KKE_STEP_FUNCTION_NAME" {
  description = "Name of the Step Functions state machine"
  type        = string
}

```

- `./outputs.tf`:


```tf
output "kke_sns_topic_name" {
  description = "Name of the SNS topic created"
  value       = module.sns.sns_topic_name
}

output "kke_ssm_parameter_name" {
  description = "Name of the SSM parameter created"
  value       = module.ssm.ssm_parameter_name
}

output "kke_step_function_name" {
  description = "Name of the Step Function created"
  value       = module.stepfunctions.step_function_name
}
```

- `./terraform.tfvars`:

```tf
KKE_SNS_TOPIC_NAME       = "devops-sns-topic"
KKE_SSM_PARAM_NAME       = "devops-param"
KKE_STEP_FUNCTION_NAME   = "devops-stepfunction"
```

## SNS module:

- `./modules/sns/main.tf`:

```tf
resource "aws_sns_topic" "this" {
  name = var.KKE_SNS_TOPIC_NAME
}
```

- `./modules/sns/outputs.tf`:

```tf
output "sns_topic_name" {
  description = "Name of the SNS topic"
  value       = aws_sns_topic.this.name
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.this.arn
}
```

## SSM parameter module:

- `./modules/ssm/main.tf`:

```tf
resource "aws_ssm_parameter" "this" {
  name  = var.KKE_SSM_PARAM_NAME
  type  = "String"
  value = "arn:aws:sns:us-east-1:000000000000:${var.KKE_SNS_TOPIC_NAME}"
}
```

- `./modules/ssm/outputs.tf`:

```tf
output "ssm_parameter_name" {
  description = "Name of the SSM parameter"
  value       = aws_ssm_parameter.this.name
}
```

## Setp Functions module:

- `./modules/stepfunctions/main.tf`:

```tf
data "aws_ssm_parameter" "sns_param" {
  name = var.KKE_SSM_PARAM_NAME
}

resource "aws_iam_role" "stepfunction" {
  name = "${var.KKE_STEP_FUNCTION_NAME}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "states.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "stepfunction_ssm" {
  name = "${var.KKE_STEP_FUNCTION_NAME}-ssm-policy"
  role = aws_iam_role.stepfunction.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ssm:GetParameter"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_sfn_state_machine" "this" {
  name     = var.KKE_STEP_FUNCTION_NAME
  role_arn = aws_iam_role.stepfunction.arn
  definition = jsonencode({
    StartAt = "ReadSSM"
    States = {
      ReadSSM = {
        Type   = "Pass"
        Result = {
          SnsArn = data.aws_ssm_parameter.sns_param.value
        }
        End = true
      }
    }
  })
    depends_on = [
    aws_iam_role_policy.stepfunction_ssm
  ]
}
```

- `./mocules/stepfunctions/outputs.tf`:

```tf
output "step_function_name" {
  description = "Name of the Step Functions state machine"
  value       = aws_sfn_state_machine.this.name
}
```



Error:

```
Step Functions data source does not depend on the SSM parameter.
```
