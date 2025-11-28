terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Get latest Ubuntu AMI -test -test
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Security Group
resource "aws_security_group" "todo_app" {
  name        = "todo-app-sg"
  description = "Security group for TODO application"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "todo-app-sg"
  }
}

# SSH Key
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.ssh_public_key
}

# EC2 Instance
resource "aws_instance" "todo_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.todo_app.id]

  root_block_device {
    volume_size = 30
  }

  tags = {
    Name = "todo-app-server"
  }

}

# Elastic IP
resource "aws_eip" "todo_server" {
  instance = aws_instance.todo_server.id
  domain   = "vpc"
}

# Ansible Inventory
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    server_ip        = aws_eip.todo_server.public_ip
    server_user      = "ubuntu"
    private_key_path = var.private_key_path
  })
  filename = "${path.module}/../ansible/inventory/hosts.ini"
  depends_on = [aws_eip.todo_server]
}

resource "null_resource" "run_ansible" {
  depends_on = [
    local_file.ansible_inventory
  ]

  provisioner "local-exec" {
    command = <<-EOT
      sleep 60
      cd ${path.module}/../ansible
      export ANSIBLE_HOST_KEY_CHECKING=False
      export DOMAIN=${var.domain}
      export ACME_EMAIL=${var.acme_email}
      export GITHUB_REPO=${var.github_repo}
      export JWT_SECRET=myfancysecret
      ansible-playbook -i inventory/hosts.ini playbook.yml
    EOT
  }
}


#
#terraform {
#  required_version = ">= 1.0"
#  
#  required_providers {
#    aws = {
#      source  = "hashicorp/aws"
#      version = "~> 5.0"
#    }
#    local = {
#      source  = "hashicorp/local"
#      version = "~> 2.4"
#    }
#    null = {
#      source  = "hashicorp/null"
#      version = "~> 3.2"
#    }
#  }
#}
#
#provider "aws" {
#  region = var.aws_region
#
#  default_tags {
#    tags = {
#      Project     = "DevOps-Stage6-TODO"
#      ManagedBy   = "Terraform"
#      Environment = "Production"
#    }
#  }
#}
#
## Get latest Ubuntu 22.04 AMI
#data "aws_ami" "ubuntu" {
#  most_recent = true
#  owners      = ["099720109477"] # Canonical
#
#  filter {
#    name   = "name"
#    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
#  }
#
#  filter {
#    name   = "virtualization-type"
#    values = ["hvm"]
#  }
#}
#
## Security Group
#resource "aws_security_group" "todo_app" {
#  name        = "todo-app-sg"
#  description = "Security group for TODO application"
#
#  # SSH
#  ingress {
#    description = "SSH"
#    from_port   = 22
#    to_port     = 22
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  # HTTP
#  ingress {
#    description = "HTTP"
#    from_port   = 80
#    to_port     = 80
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  # HTTPS
#  ingress {
#    description = "HTTPS"
#    from_port   = 443
#    to_port     = 443
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  # Traefik Dashboard (optional, remove in production)
#  ingress {
#    description = "Traefik Dashboard"
#    from_port   = 8080
#    to_port     = 8080
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  # Outbound - Allow all
#  egress {
#    description = "Allow all outbound"
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  tags = {
#    Name = "todo-app-security-group"
#  }
#
#  lifecycle {
#    create_before_destroy = true
#  }
#}
#
## EC2 Key Pair (you need to create this first)
#resource "aws_key_pair" "deployer" {
#  key_name   = var.key_name
#  public_key = file(var.public_key_path)
#}
#
## EC2 Instance
#resource "aws_instance" "todo_server" {
#  ami           = data.aws_ami.ubuntu.id
#  instance_type = var.instance_type
#  key_name      = aws_key_pair.deployer.key_name
#
#  vpc_security_group_ids = [aws_security_group.todo_app.id]
#
#  root_block_device {
#    volume_size = 30
#    volume_type = "gp3"
#    encrypted   = true
#
#    tags = {
#      Name = "todo-app-root-volume"
#    }
#  }
#
#  user_data = <<-EOF
#              #!/bin/bash
#              # Update system
#              apt-get update
#              apt-get upgrade -y
#              
#              # Set hostname
#              hostnamectl set-hostname todo-app-server
#              
#              # Create deployment user
#              useradd -m -s /bin/bash deploy
#              mkdir -p /home/deploy/.ssh
#              chmod 700 /home/deploy/.ssh
#              
#              # Allow deploy user to run Docker commands
#              usermod -aG sudo deploy
#              echo "deploy ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/deploy
#              EOF
#
#  tags = {
#    Name = "todo-app-server"
#  }
#
#  lifecycle {
#    ignore_changes = [
#      user_data,
#      ami
#    ]
#  }
#
#  # Wait for instance to be ready
#  provisioner "remote-exec" {
#    inline = [
#      "echo 'Waiting for cloud-init to complete...'",
#      "cloud-init status --wait",
#      "echo 'Instance is ready!'"
#    ]
#
#    connection {
#      type        = "ssh"
#      user        = "ubuntu"
#      private_key = file(var.private_key_path)
#      host        = self.public_ip
#      timeout     = "5m"
#    }
#  }
#}
#
## Elastic IP (optional but recommended)
#resource "aws_eip" "todo_server" {
#  instance = aws_instance.todo_server.id
#  domain   = "vpc"
#
#  tags = {
#    Name = "todo-app-eip"
#  }
#
#  depends_on = [aws_instance.todo_server]
#}
#
## Generate Ansible Inventory
#resource "local_file" "ansible_inventory" {
#  content = templatefile("${path.module}/templates/inventory.tpl", {
#    server_ip        = aws_eip.todo_server.public_ip
#    server_user      = "ubuntu"
#    private_key_path = var.private_key_path
#  })
#  filename = "${path.module}/../ansible/inventory/hosts.ini"
#
#  depends_on = [aws_eip.todo_server]
#}
#
## Wait a bit before running Ansible
#resource "time_sleep" "wait_for_instance" {
#  depends_on = [
#    aws_instance.todo_server,
#    local_file.ansible_inventory
#  ]
#
#  create_duration = "60s"
#}
#
## Run Ansible Playbook
#resource "null_resource" "run_ansible" {
#  triggers = {
#    instance_id = aws_instance.todo_server.id
#    always_run  = timestamp() # Force run on every apply (optional)
#  }
#
#  provisioner "local-exec" {
#    command     = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ../ansible/inventory/hosts.ini ../ansible/playbook.yml"
#    working_dir = path.module
#  }
#
#  depends_on = [
#    time_sleep.wait_for_instance,
#    local_file.ansible_inventory
#  ]
#}