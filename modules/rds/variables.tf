variable "project_name" {
  type = string
}

variable "subnet_ids" {
  description = "At least 2 subnet IDs in 2 different AZs"
  type        = list(string)
}

variable "security_group_id" {
  type = string
}

variable "db_name" {
  type    = string
  default = "wordpressdb"
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}
