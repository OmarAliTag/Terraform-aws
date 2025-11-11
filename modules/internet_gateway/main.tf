# modules/internet_gateway/main.tf
resource "aws_internet_gateway" "main" {
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.gow}-igw"
    }
  )
}

# modules/internet_gateway/variables.tf
variable "gow" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

# modules/internet_gateway/outputs.tf
output "igw_id" {
  value = aws_internet_gateway.main.id
}

# ============================================
