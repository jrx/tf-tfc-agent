
variable "ami_name" {
  type    = string
  default = "my-custom-ami"
}

variable "aws_access_key" {
  type    = string
  default = "${env("AWS_ACCESS_KEY_ID")}"
}

variable "aws_secret_key" {
  type    = string
  default = "${env("AWS_SECRET_ACCESS_KEY")}"
}

variable "aws_session_token" {
  type    = string
  default = "${env("AWS_SESSION_TOKEN")}"
}

variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "owner" {
  type    = string
  default = "my-user"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "rocky" {
  access_key                  = "${var.aws_access_key}"
  ami_name                    = "packer rocky ${local.timestamp}"
  associate_public_ip_address = true
  force_delete_snapshot       = true
  force_deregister            = true
  instance_type               = "t3.micro"
  region                      = "${var.aws_region}"
  secret_key                  = "${var.aws_secret_key}"
  source_ami_filter {
    filters = {
      product-code        = "cotnnspjrsi38lfn8qo4ibnnm"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["679593333241"]
  }
  ssh_username = "rocky"
  tags = {
    Name       = "Rocky Linux 8"
    OS         = "rocky"
    OS-Version = "8"
    Owner      = "${var.owner}"
  }
  token = "${var.aws_session_token}"
}

build {
  sources = ["source.amazon-ebs.rocky"]

  hcp_packer_registry {
    bucket_name = "tfc-agent"
    description = <<EOT
Setup Terraform Cloud Agents (DEMO)
    EOT
    bucket_labels = {
      "owner"      = "${var.owner}",
      "os"         = "rocky",
      "os-version" = "8",
    }

    build_labels = {
      "build-time"   = timestamp(),
      "build-source" = basename(path.cwd),
    }
  }

  provisioner "ansible" {
    playbook_file = "./ansible/tfc-agent.yml"
  }
}