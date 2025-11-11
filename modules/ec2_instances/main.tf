# modules/ec2_instances/main.tf
resource "aws_instance" "main" {
  count                  = var.instance_count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = [var.security_group_id]
  user_data              = var.user_data

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.gow}-${count.index + 1}"
    }
  )
}

# modules/ec2_instances/variables.tf
variable "gow" {
  description = "Name prefix"
  type        = string
}

variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t3.micro"
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID"
  type        = string
}

variable "user_data" {
  description = "User data script"
  type        = string
  default     = ""
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

variable "tags" {
  type    = map(string)
  default = {}
}

# modules/ec2_instances/outputs.tf
output "instance_ids" {
  description = "EC2 instance IDs"
  value       = aws_instance.main[*].id
}

output "private_ips" {
  description = "Private IP addresses"
  value       = aws_instance.main[*].private_ip
}

output "public_ips" {
  description = "Public IP addresses"
  value       = aws_instance.main[*].public_ip
}