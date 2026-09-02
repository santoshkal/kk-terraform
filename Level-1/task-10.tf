# Create Snapshot Using Terraform

resource "aws_ebs_volume" "k8s_volume" {
  availability_zone = "us-east-1a"
  size              = 5
  type              = "gp2"

  tags = {
    Name = "datacenter-vol"
  }
}

resource "aws_ebs_snapshot" "datacenter-vol-ss" {
  volume_id   = aws_ebs_volume.k8s_volume.id
  description = "Datacenter Snapshot"

  tags = {
    Name = "datacenter-vol-ss"
  }
}
