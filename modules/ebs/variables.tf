variable "project_name" {
  type = string
}

variable "availability_zone" {
  description = "Must match the AZ of the EC2 instance"
  type        = string
}

variable "instance_id" {
  description = "EC2 instance ID to attach this volume to"
  type        = string
}

variable "volume_size" {
  type    = number
  default = 10
}
