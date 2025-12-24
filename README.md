# Terraform AWS Core Infrastructure

## Overview
This project implements a **production-style, multi-tier AWS infrastructure** using **Terraform** with a fully modular and environment-driven design. The goal of this project is to demonstrate how scalable, secure cloud infrastructure is built and operated in real-world engineering environments using Infrastructure as Code and CI/CD automation.

The architecture mirrors common enterprise patterns used by platform and cloud engineering teams.

---

## Architecture
The infrastructure consists of the following layers:

### Networking
- Custom VPC
- Public and private subnets across **two Availability Zones**
- Internet Gateway for public ingress
- NAT Gateway for private outbound traffic

### Security
- Tiered security groups (ALB, application, database)
- Least-privilege IAM roles and instance profiles
- Encrypted secrets managed with **AWS Secrets Manager and KMS**

### Compute
- Application Load Balancer (ALB)
- Auto Scaling Group (ASG)
- EC2 instances launched via **Launch Templates**
- Health checks and auto-healing via ALB + ASG integration

### Data
- Amazon RDS (PostgreSQL)
- Deployed in private subnets
- Storage encryption enabled
- Master credentials generated and rotated via Secrets Manager

---

## Terraform Module Structure
terraform-aws-core-infra/
├── environments/
│ └── dev/
│ └── main.tf
├── modules/
│ ├── vpc/
│ ├── security-groups/
│ ├── alb/
│ ├── asg/
│ └── rds/



Each module is:
- Independently reusable
- Variable-driven
- Exposed through outputs for clean inter-module wiring

---

## Infrastructure as Code
- All infrastructure is defined using Terraform
- Remote state stored in **S3** with **DynamoDB state locking**
- Environment-based configuration to support dev and prod deployments
- Modular design allows individual components to evolve independently

---

## CI/CD Integration
This infrastructure is designed to be deployed through a **GitHub Actions CI/CD pipeline** using **AWS OIDC authentication**, eliminating the need for long-lived AWS credentials.

The pipeline performs:
- `terraform fmt`
- `terraform validate`
- `terraform plan`

This ensures consistent formatting, validation, and safe change previews before apply.

---

## Security Highlights
- No hardcoded secrets or credentials
- Database passwords managed automatically by AWS Secrets Manager
- KMS-backed encryption for sensitive data
- IAM roles scoped by service responsibility
- Private networking for application and database tiers

---

## Why This Project Matters
This project demonstrates the ability to:
- Design and deploy real-world AWS architectures
- Build maintainable, production-grade Terraform code
- Debug IAM, networking, and service-level issues
- Operate infrastructure via CI/CD instead of manual console changes
- Apply security-first design principles

This closely reflects the expectations for **Cloud Engineer** and **Platform Engineer** roles.

---

## Technologies Used
- Terraform
- AWS VPC
- EC2
- Application Load Balancer (ALB)
- Auto Scaling Group (ASG)
- Amazon RDS (PostgreSQL)
- AWS IAM
- AWS Secrets Manager
- AWS KMS
- GitHub Actions
- Amazon S3 and DynamoDB (Terraform state)

---

## Status
✅ **Completed**

The infrastructure is fully deployed, validated, and CI/CD-ready.
