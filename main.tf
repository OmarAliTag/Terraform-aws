# Root main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  gow      = var.project_name
  vpc_cidr = var.vpc_cidr
  tags     = var.common_tags
}

# Public Subnets Module
module "public_subnets" {
  source = "./modules/public_subnets"

  gow                  = var.project_name
  vpc_id               = module.vpc.vpc_id
  public_subnet_cidrs  = var.public_subnet_cidrs
  availability_zones   = var.availability_zones
  tags                 = var.common_tags
}

# Private Subnets Module
module "private_subnets" {
  source = "./modules/private_subnets"

  gow                   = var.project_name
  vpc_id                = module.vpc.vpc_id
  private_subnet_cidrs  = var.private_subnet_cidrs
  availability_zones    = var.availability_zones
  tags                  = var.common_tags
}

# Internet Gateway Module
module "internet_gateway" {
  source = "./modules/internet_gateway"

  gow    = var.project_name
  vpc_id = module.vpc.vpc_id
  tags   = var.common_tags
}

# NAT Gateway Module
module "nat_gateway" {
  source = "./modules/nat_gateway"

  gow              = var.project_name
  public_subnet_id = module.public_subnets.subnet_ids[0]
  tags             = var.common_tags

  depends_on = [module.internet_gateway]
}

# Route Tables Module
module "route_tables" {
  source = "./modules/route_tables"

  gow                 = var.project_name
  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.internet_gateway.igw_id
  nat_gateway_id      = module.nat_gateway.nat_gateway_id
  public_subnet_ids   = module.public_subnets.subnet_ids
  private_subnet_ids  = module.private_subnets.subnet_ids
  tags                = var.common_tags
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security_groups"

  gow    = var.project_name
  vpc_id = module.vpc.vpc_id
  tags   = var.common_tags
}

# Proxy EC2 Instances (in Public Subnets)
module "proxy_instances" {
  source = "./modules/ec2_instances"

  gow               = "${var.project_name}-proxy"
  instance_count    = 2
  ami_id            = "ami-0bdd88bd06d16ba03"
  instance_type     = var.proxy_instance_type
  subnet_ids        = module.public_subnets.subnet_ids
  security_group_id = module.security_groups.proxy_sg_id
  user_data         = file("${path.module}/scripts/proxy_userdata.sh")
  tags              = merge(var.common_tags, { Role = "Proxy" })
}

# Backend Web Server Instances (in Private Subnets)
module "backend_instances" {
  source = "./modules/ec2_instances"

  gow               = "${var.project_name}-backend"
  instance_count    = 2
  ami_id            = "ami-0bdd88bd06d16ba03"
  instance_type     = var.backend_instance_type
  subnet_ids        = module.private_subnets.subnet_ids
  security_group_id = module.security_groups.backend_sg_id
  user_data         = file("${path.module}/scripts/backend_userdata.sh")
  tags              = merge(var.common_tags, { Role = "Backend" })
}

# Application Load Balancer (optional)
module "alb" {
  source = "./modules/alb"

  gow               = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.public_subnets.subnet_ids
  security_group_id = module.security_groups.alb_sg_id
  target_instances  = module.proxy_instances.instance_ids
  tags              = var.common_tags
}