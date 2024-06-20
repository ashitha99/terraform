resource "aws_security_group" "strapi_sg" {
  name        = "strapi_sg"
  description = "Allow SSH, HTTP, and custom port traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere (not recommended for production)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from anywhere
  }

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow custom port 1337 from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

resource "aws_instance" "strapi_instance" {
  ami           = "ami-0f58b397bc5c1f2e8"  # Replace with a suitable AMI for your region
  instance_type = "t2.micro"  # Choose an instance type
  key_name      = "terraform-test"  # Replace with your key pair name

  vpc_security_group_ids = [aws_security_group.strapi_sg.id]  # Associate the security group

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y nodejs npm
              git clone https://github.com/ashitha99/strapi-terraform.git /home/ubuntu/strapi-terraform
              cd /home/ubuntu/strapi terraform
              sudo npm install strapi@beta -g
              strapi new my-project --dbclient=sqlite
              cd my-project
              echo "module.exports = { server: { host: '0.0.0.0', port: 1337 } };" > config/env/development/server.js
              pm2 start npm --name 'strapi' -- run develop
              EOF
}

# Output the public IP address of the instance
output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.strapi_instance.public_ip
}
