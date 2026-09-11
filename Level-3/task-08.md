# Hosting a Static Website on Amazon S3 with Custom Configuration Using Terraform

The Nautilus DevOps team has been tasked with creating an internal information portal for public access. As part of this project, they need to host a static website on AWS using an S3 bucket. The S3 bucket must be configured for public access to allow external users to access the static website directly via the S3 website URL.

Your task is to create a Terraform module named s3-static-site to handle the creation and configuration of the S3 bucket. For uploading the index.html file, you may use either Terraform or the AWS CLI.

Task Requirements:

- The module directory /home/bob/terraform/modules/s3-static-site/ is already created, configure the module to perform the following tasks:

- Create an S3 bucket named datacenter-web-552463081.

- Configure the S3 bucket for static website hosting with index.html as the index document.

- Allow public access to the bucket by attaching the appropriate bucket policy.

Within the module, use a variables.tf file that must define the following variables: bucket_name and index_document. These values should not be hardcoded directly into resource definitions. You may add other variables if needed to avoid hardcoding. Use these variables in main.tf for configuring the bucket.

- Within the module use outputs.tf file to output the following:

    - website_url: S3 static website url

- Your S3 website url should look something like the following, aws:4566 refers to the mock AWS endpoint configured in your environment (e.g., using LocalStack):

- http://aws:4566/<bucketname>/index.html

- The S3 bucket must be tagged with the key Project and the value StaticWeb.

- In the root main.tf, call the s3-static-site module using the required input variables (bucket_name, index_document).

- Upload the index.html file from /home/bob/terraform directory to the S3 bucket. This can be done using either the AWS CLI or Terraform (aws_s3_object).


Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.


---

# Solution

## Directory structure:

```bash
.
├── README.MD
├── index.html
├── main.tf
├── modules
│   └── s3-static-site
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── outputs.tf
└── provider.tf
```

## Module:
`./modules/s3-static-site/main.tf`:

```tf
resource "aws_s3_bucket" "kke_bucket" {
  bucket = var.bucket_name

  tags = {
    Project        = var.tag_value
  }
}

resource "aws_s3_object" "kke_object" {
  key        = var.index_document
  bucket     = aws_s3_bucket.kke_bucket.id
  source     = var.index_document_path
}
```

- `./modules/s3-static-site/variables.tf`:

```tf
variable "bucket_name"{
    type = string
}

variable "index_document"{
    type = string
}

variable "tag_value"{
    type = string
}

variable "index_document_path"{
    type = string
}
```

- `./modules/s3-static-site/outputs.tf`:

```tf
output "website_url"{
    description = "S3 static website url"
    value = "http://aws:4566/${aws_s3_bucket.kke_bucket.bucket}/index.html"
}
```


## Root Module:

- `./main.tf`:

```tf
locals {
  bucket_name         = "nautilus-web-46872378"
  index_document      = "index.html"
  index_document_path = "/home/bob/terraform/index.html"
  tag_value           = "StaticWeb"
}

module "s3-static-site" {
  source              = "./modules/s3-static-site"
  bucket_name         = local.bucket_name
  index_document      = local.index_document
  index_document_path = local.index_document_path
  tag_value           = local.tag_value
}
```

- `./outputs.tf`:

```tf
output "website_url" {
  description = "S3 static website URL"
  value       = module.s3-static-site.website_url
}
```
