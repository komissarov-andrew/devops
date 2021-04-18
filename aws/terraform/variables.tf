variable "aws_region" {}
variable "aws_key_name" {}
variable "instance_ami" {}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_cidr_public_1" {
  description = "CIDR for the public subnet a zone"
  default     = "10.0.1.0/24"
}

variable "vpc_cidr_public_2" {
  description = "CIDR for the public subnet b zone"
  default     = "10.0.2.0/24"
}

variable "db_user" {
  description = "DB username"
}

variable "db_password" {
  description = "DB password"
}

variable "db_name" {
  description = "db name"
}

variable "ssh_key" {
  default     = "~/.ssh/app.pub"
  description = "Default pub key"
}

variable "ssh_priv_key" {
  default     = "~/.ssh/app"
  description = "Default pub key"
}
