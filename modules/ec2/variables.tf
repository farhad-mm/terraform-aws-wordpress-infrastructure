variable "project_name" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet to launch the instance in (from the networking module)"
  type        = string
}

variable "security_group_id" {
  description = "Security group to attach (from the networking module)"
  type        = string
}

variable "user_data" {
  description = "Bootstrap script content (install_wordpress.sh)"
  type        = string
}
