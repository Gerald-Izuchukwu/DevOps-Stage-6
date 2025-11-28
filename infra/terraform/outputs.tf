output "server_public_ip" {
  description = "Public IP address of the TODO server"
  value       = aws_eip.todo_server.public_ip
}

output "server_id" {
  description = "EC2 instance ID"
  value       = aws_instance.todo_server.id
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.todo_app.id
}

output "ssh_command" {
  description = "SSH command to connect to server"
  value       = "ssh -i ${var.private_key_path} ubuntu@${aws_eip.todo_server.public_ip}"
}

output "application_url" {
  description = "Application URL"
  value       = "https://${var.domain}"
}

output "ansible_inventory_path" {
  description = "Path to generated Ansible inventory"
  value       = abspath("${path.module}/../ansible/inventory/hosts.ini")
}

#test for drift