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
