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
resource "aws_instance" "strapi2" {
  ami                         = "ami-0f58b397bc5c1f2e8"
  instance_type               = "t2.medium"
  subnet_id              = "subnet-0c724a9e1beb09e35"
  vpc_security_group_ids = [aws_security_group.strapi_sg.id]
  key_name = "terraform"
  associate_public_ip_address = true
  user_data                   = <<-EOF
                                #!/bin/bash
                                sudo apt update
                                curl -fsSL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh
                                sudo bash -E nodesource_setup.sh
                                sudo apt update && sudo apt install nodejs -y
                                sudo npm install -g yarn && sudo npm install -g pm2
                                echo -e "skip\n" | npx create-strapi-app simple-strapi --quickstart
                                cd simple-strapi
                                echo "const strapi = require('@strapi/strapi');
                                strapi().start();" > server.js
                                pm2 start server.js --name strapi
                                pm2 save && pm2 startup
                                sleep 360
                                EOF

  tags = {
    Name = "my_strapi"
  }
}


# Output the public IP address of the instance
output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.strapi_instance.public_ip
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
  }
}

provider "aws" {
  region = "ap-south-1"  # Replace with your preferred region
}

variable "private_key_path" {
  description = "Path to the private key file used for SSH connection"
  default     = "C:\\Users\\91807\\OneDrive\\Desktop\\terraform-test.pem"
}
