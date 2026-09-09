data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "tls_private_key" "wordpress" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "wordpress" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.wordpress.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.wordpress.private_key_pem
  filename        = "${path.module}/../../${var.project_name}-key.pem"
  file_permission = "0400"
}

resource "aws_instance" "wordpress" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = aws_key_pair.wordpress.key_name
  user_data              = var.user_data

  tags = {
    Name    = "${var.project_name}-wordpress"
    Project = var.project_name
  }
}
