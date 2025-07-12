packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "rde-ami"
  instance_type = "t2.micro"
  region        = "eu-west-3"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-noble-24.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "rde"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "file" {
    source      = "keys/rde.pub"
    destination = "/tmp/rde.pub"
  }
  provisioner "file" {
    source      = "images/github-prep.sh"
    destination = "/tmp/github-prep.sh"
  }
  provisioner "shell" {
    script = "./images/setup.sh"
  }
  provisioner "file" {
    source      = "bin/test-tools"
    destination = "/tmp/test-tools"
  }
  provisioner "shell" {
    inline = [
      "chmod +x /tmp/test-tools",
      "sudo /tmp/test-tools",
      "rm /tmp/test-tools"
    ]
  }
}

