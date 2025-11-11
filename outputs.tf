# Root outputs.tf
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.public_subnets.subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.private_subnets.subnet_ids
}

output "proxy_instance_ids" {
  description = "Proxy EC2 instance IDs"
  value       = module.proxy_instances.instance_ids
}

output "proxy_public_ips" {
  description = "Proxy EC2 public IPs"
  value       = module.proxy_instances.public_ips
}

output "backend_instance_ids" {
  description = "Backend EC2 instance IDs"
  value       = module.backend_instances.instance_ids
}

output "backend_private_ips" {
  description = "Backend EC2 private IPs"
  value       = module.backend_instances.private_ips
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.alb_dns_name
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = module.nat_gateway.nat_gateway_id
}