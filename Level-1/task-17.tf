# Create DynamoDB Table Using Terraform


# Set the name and primary_key as per task requirements
resource "aws_dynamodb_table" "datacenter-users" {
  name         = "datacenter-users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "datacenter_id"

  attribute {
    name = "datacenter_id"
    type = "S"
  }
}
