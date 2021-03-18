variable "cluster_name" {
  description = "Name of the cluster."
  default     = "example"
}

variable "owner" {
  description = "Owner tag on all resources."
  default     = "myuser"
}

variable "key_name" {
  description = "Specify the AWS ssh key to use."
}

variable "private_key" {
  description = "SSH private key to provision the cluster instances."
}

variable "aws_region" {
  default = "eu-north-1"
}

variable "aws_azs" {
  type        = list(any)
  description = "List of the availability zones to use."
  default     = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
}

variable "amis" {
  type = map(string)
  default = {
    eu-north-1 = "ami-095730fa90d6226bc"
  }
}

variable "instance_username" {
  default = "centos"
}

variable "num_tfc_agent" {
  description = "Specify the amount of tfc agents."
  default     = 1
}

variable "tfc_agent_version" {
  default     = "latest"
  description = "Specifies which tfc-agent version instruction to use."
}
variable "tfc_agent_token" {
  default     = "example-token"
  description = "Specifies which tfc-agent token to use."
}

variable "tfc_agent_instance_type" {
  description = "tfc-agent server instance type."
  default     = "t3.micro"
}