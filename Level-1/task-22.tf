# OpenSearch Setup Using Terraform

resource "aws_opensearch_domain" "devops-domain" {
  domain_name = "devops-es"

  tags = {
    Name = "devops-es"
  }
}

# This might take some time to create resources
