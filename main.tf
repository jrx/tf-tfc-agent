provider "hcp" {}

provider "aws" {
  region = var.aws_region
}

data "hcp_packer_iteration" "rocky" {
  bucket_name = "tfc-agent"
  channel     = "stable"
}

data "hcp_packer_image" "rocky_eu_north_1" {
  bucket_name    = "tfc-agent"
  cloud_provider = "aws"
  iteration_id   = data.hcp_packer_iteration.rocky.ulid
  region         = var.aws_region
}

resource "aws_instance" "tfc_agent" {
  ami                         = data.hcp_packer_image.rocky_eu_north_1.cloud_image_id
  instance_type               = var.tfc_agent_instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.default.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.tfc_agent_profile.name
  count                       = var.num_tfc_agent

  availability_zone = data.terraform_remote_state.vpc.outputs.aws_azs[count.index % length(data.terraform_remote_state.vpc.outputs.aws_azs)]
  subnet_id         = data.terraform_remote_state.vpc.outputs.aws_public_subnets[count.index % length(data.terraform_remote_state.vpc.outputs.aws_azs)]

  user_data = data.template_file.user_data[count.index].rendered

  tags = {
    Name  = "${var.cluster_name}-tfc-agent-${count.index}"
    Owner = var.owner
    # Keep = ""
    tfc-agent = var.cluster_name
  }
}

data "template_file" "user_data" {
  count    = var.num_tfc_agent
  template = file("${path.module}/templates/user_data.tpl")
  vars = {
    tfc_agent_token = var.tfc_agent_token
    tfc_agent_name  = "${var.cluster_name}-tfc-agent-${count.index}"
    tfc_agent_image = var.tfc_agent_image
  }
}