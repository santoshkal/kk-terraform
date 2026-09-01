# Create Security Group Using Terraform

resource "aws_security_group" "xfusion-sg" {
# Update the name and descroiption as per requirements
  name        = "xfusion-sg"
  description = "Security group for Nautilus App Servers"

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "SSH"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
