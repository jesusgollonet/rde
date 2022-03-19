terraform {
  cloud {
    organization = "jgb"
    workspaces {
      name = "rde"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.26.0"
    }
  }
  required_version = ">= 0.14.5"
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "rde" {
  ami           = var.ami
  instance_type = "t3.micro"
}
