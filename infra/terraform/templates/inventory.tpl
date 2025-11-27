[todo_servers]
todo-server ansible_host=${server_ip} ansible_user=${server_user} ansible_ssh_private_key_file=${private_key_path}

[todo_servers:vars]
ansible_python_interpreter=/usr/bin/python3