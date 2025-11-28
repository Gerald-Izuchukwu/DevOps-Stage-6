variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "devops-stage6-key"
}

variable "public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default = "~/.ssh/devops_stage6.pub" 
}

variable "private_key_path" {
  description = "Path to SSH private key"
  type        = string
  default     = "~/.ssh/devops_stage6"
}

variable "domain" {
  description = "Domain name for the application"
  type        = string
}

variable "acme_email" {
  description = "Email for Let's Encrypt certificates"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository URL"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key content (for CI/CD)"
  type        = string
  default     = ""
  sensitive   = true
}