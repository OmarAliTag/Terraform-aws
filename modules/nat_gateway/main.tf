# modules/nat_gateway/main.tf
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.gow}-nat-eip"
    }
  )
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.public_subnet_id

  tags = merge(
    var.tags,
    {
      Name = "${var.gow}-nat-gw"
    }
  )
}

# modules/nat_gateway/variables.tf
variable "gow" {
  type = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for NAT Gateway"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

# modules/nat_gateway/outputs.tf
output "nat_gateway_id" {
  value = aws_nat_gateway.main.id
}

output "nat_eip" {
  value = aws_eip.nat.public_ip
}