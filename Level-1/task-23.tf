# Secrets Manager Setup Using Terraform


resource "aws_secretsmanager_secret" "xfusion_secret" {
  name = "xfusion-secret"
}

resource "aws_secretsmanager_secret_version" "xfusion_secret_version" {
  secret_id = aws_secretsmanager_secret.xfusion_secret.id

  secret_string = jsonencode({
    username = "admin"
    password = "Namin123"
  })
}
