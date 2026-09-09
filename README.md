# Terraform AWS WordPress Infrastructure

Fully automated, modular AWS infrastructure for a WordPress deployment, built entirely with Terraform (Infrastructure as Code). Every resource is created, verified, and torn down through code — no manual console configuration.

## Architecture

- VPC (10.0.0.0/16) with 2 public subnets across 2 Availability Zones (eu-west-3a/b)
- EC2 t3.micro running Ubuntu 24.04, Apache + PHP + WordPress
- RDS MySQL 8.0 (db.t3.micro) spread across 2 AZs via a DB subnet group
- 10 GB EBS gp3 volume attached to the EC2 instance for persistent storage
- Security group scoping MySQL access to VPC-only traffic
- Self-signed TLS/HTTPS bonus on port 443

## Structure

```
.
├── main.tf                  # Root module: wires networking, ec2, rds, ebs together
├── variables.tf             # Root-level variables (project_name, db credentials)
├── install_wordpress.sh     # EC2 boot script: installs Apache/PHP, mounts EBS, configures WordPress, sets up HTTPS
└── modules/
    ├── networking/          # VPC, subnets, IGW, route table, security group
    ├── ec2/                 # AMI lookup, SSH key generation, EC2 instance
    ├── ebs/                 # Persistent disk creation and attachment
    └── rds/                 # Managed MySQL database + DB subnet group
```

## Key design decisions

- **No hardcoded secrets**: `db_password` has no default value and is supplied via `TF_VAR_db_password` at runtime — Terraform refuses to run without it.
- **Dynamic AMI lookup**: the Ubuntu AMI is resolved live via a `data` source (owner-restricted to Canonical), instead of a hardcoded, region-specific ID that would eventually go stale.
- **Modular design**: networking, ec2, ebs, and rds are each self-contained modules with their own inputs/outputs, so the environment is fully reusable and not copy-pasted.
- **Nitro-safe disk detection**: the boot script detects the attached EBS device dynamically via `lsblk`, since modern Nitro-based instances often rename `/dev/sdf` to `/dev/nvme1n1`.

## Deploying

```bash
terraform init
export TF_VAR_db_password='YourStrongPassword'
terraform plan
terraform apply
```

## Tearing down

```bash
terraform destroy
```

## Notes

This infrastructure was deployed and verified (HTTP + HTTPS access confirmed) on AWS, then destroyed after verification to avoid ongoing cost — standard practice for a training/demo environment. No live infrastructure is currently running from this repository.
