# Managing CI/CD Pipelines Using Terraform

The DevOps team is designing a Terraform-based infrastructure to simulate real-world, production-grade deployments with strict adherence to best practices. The infrastructure must be reusable, modular, and environment-specific (dev and prod).

Requirements:

Create modules under modules/ named:

- dynamodb: Provision a DynamoDB table named datacenter-<env>-table (based on the environment)(dev & prod), using id as the HASH key.
- secretsmanager: to provision a Secrets Manager secret named datacenter-<env>-secret.
- elasticsearch: to provision an Elasticsearch domain named datacenter-<env>-es.

- Create a secret value datacenter-<env>-value.(dev & prod).

- Each environment dev and prod MUST be located under /home/bob/terraform/env/. Terraform commands will be executed from within each environment directory.

- Use absolute-path symbolic links (/home/bob/terraform/) in each environment dev/prod for the shared Terraform files main.tf, variables.tf, and shared modules. Within each environment directory, the modules/ directory MUST be a symbolic link pointing to /home/bob/terraform/modules.

- If you define the outputs in a separate outputs.tf under /home/bob/terraform (instead of inside main.tf), you MUST also create an absolute-path symbolic link to it in each environment directory so the outputs are available when running Terraform from within dev/prod.

- Keep a separate terraform_config.tf in each environment to define environment-specific configuration modules, environment variables, overrides. This file should NOT be a symlink.

- Use main.tf file under /home/bob/terraform to define all shared resources and environment-specific modules, ensuring clarity, modularity, and maintainability.

- Use the variables.tf file under /home/bob/terraform with the following variables:

    - KKE_ENV: name of the Environment used.(dev or prod)
    - KKE_DYNAMODB_TABLE_NAME: name of the dynamodb table.
    - KKE_SECRET_NAME: name of the secret.
    - KKE_SECRET_VALUE: secret value.
    - KKE_ELASTICSEARCH_DOMAIN: domain of the elasticsearch.

- Use dev.tfvars and prod.tfvars with respect to the variables.tf file under /home/bob/terraform/env/<env-name>/. Terraform plans will be executed using these files explicitly.

- Define the following outputs (either inside main.tf or in a separate outputs.tf under /home/bob/terraform):

    - kke_table_name:exposes the name of the created DynamoDB table
    - kke_secret_arn :provides the ARN of the Secrets Manager secret
    - kke_elasticsearch_endpoint: returns the endpoint of the Elasticsearch domain

Notes:
The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Ensure all environment directories reference shared modules via symlinks and no module code is duplicated.

Ensure that the variables.tf and main.tf files (and outputs.tf, if you keep outputs in a separate file) in each environment directory use absolute-path symbolic links.

Resources must be named uniquely per environment.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.


---

# Solution:

## Directory structure:

```bash
/home/bob/terraform/
├── main.tf
├── variables.tf
├── outputs.tf
│
├── modules/
│   ├── dynamodb/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── secretsmanager/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── elasticsearch/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── env/
    ├── dev/
    │   ├── main.tf -> /home/bob/terraform/main.tf
    │   ├── variables.tf -> /home/bob/terraform/variables.tf
    │   ├── outputs.tf -> /home/bob/terraform/outputs.tf
    │   ├── modules/ -> /home/bob/terraform/modules
    │   ├── terraform_config.tf
    │   └── dev.tfvars
    │
    └── prod/
        ├── main.tf -> /home/bob/terraform/main.tf
        ├── variables.tf -> /home/bob/terraform/variables.tf
        ├── outputs.tf -> /home/bob/terraform/outputs.tf
        ├── modules/ -> /home/bob/terraform/modules
        ├── terraform_config.tf
        └── prod.tfvars
```

## Create required absolute-path symlinks

```bash
# --- dev environment ---
cd env/dev
ln -s /home/bob/terraform/main.tf main.tf
ln -s /home/bob/terraform/variables.tf variables.tf
ln -s /home/bob/terraform/outputs.tf outputs.tf
ln -s /home/bob/terraform/modules/ modules

# --- prod environment ---
cd ../prod
ln -s /home/bob/terraform/main.tf main.tf
ln -s /home/bob/terraform/variables.tf variables.tf
ln -s /home/bob/terraform/outputs.tf outputs.tf
ln -s /home/bob/terraform/modules/ modules

```

### Verify if symlinks are created as desired:

```bash
ls -l /home/bob/terraform/env/dev
ls -l /home/bob/terraform/env/prod
```

## Root module configs:
- `./variables.tf`:

```tf
# variables.tf

variable "KKE_ENV" {
  description = "Environment name"
  type        = string
}

variable "KKE_DYNAMODB_TABLE_NAME" {
  description = "DynamoDB table name"
  type        = string
}

variable "KKE_SECRET_NAME" {
  description = "Secrets Manager secret name"
  type        = string
}

variable "KKE_SECRET_VALUE" {
  description = "Secrets Manager secret value"
  type        = string
}

variable "KKE_ELASTICSEARCH_DOMAIN" {
  description = "Elasticsearch domain name"
  type        = string
}
```

- `./main.tf`:

```tf
module "dynamodb" {
  source     = "./modules/dynamodb"
  KKE_DYNAMODB_TABLE_NAME = var.KKE_DYNAMODB_TABLE_NAME
  KKE_ENV        = var.KKE_ENV
}

module "secretsmanager" {
  source       = "./modules/secretsmanager"
  KKE_SECRET_NAME  = var.KKE_SECRET_NAME
  KKE_SECRET_VALUE = var.KKE_SECRET_VALUE
}

module "elasticsearch" {
  source      = "./modules/elasticsearch"
  KKE_ELASTICSEARCH_DOMAIN = var.KKE_ELASTICSEARCH_DOMAIN
  KKE_ENV         = var.KKE_ENV
}
```

- `./outputs.tf`:

```tf
output "kke_table_name" {
  value = module.dynamodb.table_name
}

output "kke_secret_arn" {
  value = module.secretsmanager.secret_arn
}

output "kke_elasticsearch_endpoint" {
  value = module.elasticsearch.kke_elasticsearch_endpoint
}
```


## Dynamodb module:

- `.modules/dynamodb/variables.tf`:

```tf
variable "KKE_DYNAMODB_TABLE_NAME" {
  type = string
}

variable "KKE_ENV" {
  type = string
}
```

- `./modules/dynamodb/main.tf`:

```tf
resource "aws_dynamodb_table" "this" {
  name         = var.KKE_DYNAMODB_TABLE_NAME
  hash_key     = "id"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Environment = var.KKE_ENV
  }
}
```

- `./modules/dynamodb/outputs.tf`:

```tf
output "table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.this.name
}
```

## Secretsmanager module:

- `./modules/secretsmanager/variables.tf`:

```tf
variable "KKE_SECRET_NAME" {
  type = string
}

variable "KKE_SECRET_VALUE" {
  type = string
}
```

- `./modules/secretsmanager/main.tf`:

```tf
resource "aws_secretsmanager_secret" "this" {
  name = var.KKE_SECRET_NAME
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = var.KKE_SECRET_VALUE
}
```

- `./modules/secretsmanager/outputs.tf`:

```tf
output "secret_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.this.arn
}
```

## Elasticsearch module:

- `./modules/elasticsearch/variables.tf`:

```tf
variable "KKE_ELASTICSEARCH_DOMAIN" {
  type = string
}

variable "KKE_ENV" {
  type = string
}
```

- `./modules/elasticsearch/main.tf`:

```tf
resource "aws_elasticsearch_domain" "this" {
  domain_name           = var.KKE_ELASTICSEARCH_DOMAIN
  elasticsearch_version = "7.10"

  cluster_config {
    instance_type  = "t3.small.elasticsearch"
    instance_count = 1
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }

  tags = {
    Environment = var.KKE_ENV   
  }
}
```

- `./modules/elasticsearch/outputs.tf`:

```tf
output "kke_elasticsearch_endpoint" {
  value = aws_elasticsearch_domain.this.endpoint
}
```


## Env specific configs:

- `./env/dev/terraform_config.tf`:

```tf
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
```

- `./env/prod/terraform_config.tf`:

```tf
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
```

- `./env/dev/dev.tfvars`:

```tf:
KKE_ENV                    = "dev"
KKE_DYNAMODB_TABLE_NAME    = "datacenter-dev-table"
KKE_SECRET_NAME            = "datacenter-dev-secret"
KKE_SECRET_VALUE           = "datacenter-dev-value"
KKE_ELASTICSEARCH_DOMAIN   = "datacenter-dev-es"
```

- ./env/prod/prod.tfvars`:

```tf
KKE_ENV                    = "prod"
KKE_DYNAMODB_TABLE_NAME    = "datacenter-prod-table"
KKE_SECRET_NAME            = "datacenter-prod-secret"
KKE_SECRET_VALUE           = "datacenter-prod-value"
KKE_ELASTICSEARCH_DOMAIN   = "datacenter-prod-es"
```


## Applying configs for each env:

### Dev Env
```bash
cd ./env/dev

terraform init
terraform fmt
terraform validate 
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

### Prod Env:

```bash
cd ./env/prod

terraform init
terraform fmt
terraform validate
terraform plan -var-file=prod.tfvars
terraform apply -var-file=prod.tfvars
```
