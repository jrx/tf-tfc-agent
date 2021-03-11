provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "tfc_agent" {
  ami                         = var.amis[var.aws_region]
  instance_type               = var.tfc_agent_instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.default.id]
  associate_public_ip_address = true
  count                       = var.num_tfc_agent

  availability_zone = data.terraform_remote_state.vpc.outputs.aws_azs[count.index % length(data.terraform_remote_state.vpc.outputs.aws_azs)]
  subnet_id         = data.terraform_remote_state.vpc.outputs.aws_public_subnets[count.index % length(data.terraform_remote_state.vpc.outputs.aws_azs)]

  tags = {
    Name  = "${var.cluster_name}-tfc-agent-${count.index}"
    Owner = var.owner
    # Keep = ""
    tfc-agent = var.cluster_name
  }
}

resource "null_resource" "ansible" {
  count = var.num_tfc_agent

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.instance_username}/ansible",
      "sudo yum -y install epel-release",
      "sudo yum -y install ansible",
    ]
  }

  provisioner "file" {
    source      = "./ansible/"
    destination = "/home/${var.instance_username}/ansible/"
  }

  provisioner "remote-exec" {
    inline = [
      "cd ansible; ansible-playbook -c local -i \"localhost,\" -e 'TFC_AGENT_NAME=${var.cluster_name}-tfc-agent-${count.index} TFC_AGENT_VERSION=${var.tfc_agent_version} TFC_AGENT_TOKEN=${var.tfc_agent_token}' tfc-agent.yml",
    ]
  }

  connection {
    host        = coalesce(element(aws_instance.tfc_agent.*.public_ip, count.index), element(aws_instance.tfc_agent.*.private_ip, count.index))
    type        = "ssh"
    user        = var.instance_username
    private_key = var.private_key
  }

  triggers = {
    always_run = timestamp()
  }
}