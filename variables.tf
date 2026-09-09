variable "project_name" {
  type    = string
  default = "farhad-wais-tf-wordpress"
}

variable "db_username" {
  type      = string
  default   = "wpadmin"
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}
