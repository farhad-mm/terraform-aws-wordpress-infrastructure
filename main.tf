terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

module "networking" {
  source       = "./modules/networking"
  project_name = var.project_name
}

module "rds" {
  source             = "./modules/rds"
  project_name       = var.project_name
  subnet_ids         = module.networking.public_subnet_ids
  security_group_id  = module.networking.web_sg_id
  db_username        = var.db_username
  db_password        = var.db_password
}

module "ec2" {
  source             = "./modules/ec2"
  project_name       = var.project_name
  subnet_id          = module.networking.public_subnet_ids[0]
  security_group_id  = module.networking.web_sg_id
  user_data = templatefile("${path.module}/install_wordpress.sh", {
    db_endpoint = module.rds.db_endpoint
    db_name     = module.rds.db_name
    db_username = var.db_username
    db_password = var.db_password
  })
}

module "ebs" {
  source             = "./modules/ebs"
  project_name       = var.project_name
  availability_zone  = module.ec2.availability_zone
  instance_id        = module.ec2.instance_id
}

output "wordpress_public_ip" {
  value = module.ec2.public_ip
}

output "database_endpoint" {
  value = module.rds.db_endpoint
}
