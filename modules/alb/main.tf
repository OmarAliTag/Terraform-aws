# modules/alb/main.tf
resource "aws_lb" "main" {
  name               = "${var.gow}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(
    var.tags,
    {
      Name = "${var.gow}-alb"
    }
  )
}

resource "aws_lb_target_group" "main" {
  name     = "${var.gow}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.gow}-tg"
    }
  )
}

resource "aws_lb_target_group_attachment" "main" {
  count            = length(var.target_instances)
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = var.target_instances[count.index]
  port             = 80
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# modules/alb/variables.tf
variable "gow" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "target_instances" {
  description = "List of instance IDs to add to target group"
  type        = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}

# modules/alb/outputs.tf
output "alb_arn" {
  value = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.main.arn
}