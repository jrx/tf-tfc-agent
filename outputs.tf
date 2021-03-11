output "tfc_agent_public_ip" {
  value = aws_instance.tfc_agent.*.public_ip
}