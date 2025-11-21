# IAM role for EC2 to allow SSM
resource "aws_iam_role" "ec2_ssm_role" {
  name = "${var.project}-ec2-ssm-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "${var.project}-profile-${var.env}"
  role = aws_iam_role.ec2_ssm_role.name
}

# Security Group allowing outbound for SSM and inbound (optional)
resource "aws_security_group" "instance_sg" {
  name        = "${var.project}-sg-${var.env}"
  description = "Allow SSH (optional) + HTTP for demo"
  vpc_id      = "" # populate if you run in VPC; otherwise supply via var or remove

  # Example ingress - adjust to your needs
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "http"
  }

  # Allow all outbound (for SSM, updates)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch EC2 instances (simple example)
resource "aws_instance" "app" {
  count         = var.instance_count
  ami           = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name
  vpc_security_group_ids = var.vpc_id != "" ? [aws_security_group.instance_sg.id] : []
  tags = {
    Name        = "${var.project}-app-${var.env}-${count.index}"
    Environment = var.env
    Role        = "backend"   # you can create multiple aws_instance resources for frontend/backend or use user_data to configure roles
    Project     = var.project
  }

  # user_data to install dependencies if needed
  user_data = <<-EOF
              #!/bin/bash
              # Example: install nginx as demo (Amazon Linux 2)
              yum update -y
              yum install -y nginx
              systemctl enable nginx
              systemctl start nginx
              EOF
}

# If ami not set, get Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Output instance private IPs and ids
output "instances" {
  value = [
    for i in aws_instance.app: {
      id  = i.id
      private_ip = i.private_ip
      public_ip = i.public_ip
      tags = i.tags
    }
  ]
}