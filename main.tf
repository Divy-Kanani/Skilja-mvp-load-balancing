data "aws_ssm_parameter" "vpc_id" {
  name = "/vpc/vpc_id"
}

data "aws_ssm_parameter" "public_subnets" {
  name = "/vpc/public_subnets"
}

# Create Network Load Balancer (NLB)
resource "aws_lb" "network_lb" {
  name               = "network-lb"
  load_balancer_type = "network"
  internal           = false

  subnets = split(",", data.aws_ssm_parameter.public_subnets.value)

  tags = {
    Name = "network-lb"
  }
}

# Create Application Load Balancer (ALB)
resource "aws_lb" "application_lb" {
  name               = "application-lb"
  load_balancer_type = "application"
  internal           = false

  subnets = split(",", data.aws_ssm_parameter.public_subnets.value)

  tags = {
    Name = "application-lb"
  }
}

# Create Network Load Balancer (NLB) Listener
resource "aws_lb_listener" "network_lb_listener" {
  load_balancer_arn = aws_lb.network_lb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.network_lb_target_group.arn
  }
}

# Create Application Load Balancer (ALB) Listener
resource "aws_lb_listener" "application_lb_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application_lb_target_group.arn
  }
}

# Create Network Load Balancer (NLB) Target Group
resource "aws_lb_target_group" "network_lb_target_group" {
  name     = "network-lb-target-group"
  port     = 80
  protocol = "TCP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value

  health_check {
    port     = 80
    protocol = "TCP"
  }
}

# Application Load Balancer (ALB) Target Group
resource "aws_lb_target_group" "application_lb_target_group" {
  name     = "application-lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value

  health_check {
    path     = "/"
    protocol = "HTTP"
  }
}

# NLB to ALB Target Group Attachment
resource "aws_lb_target_group_attachment" "nlb_to_alb_attachment" {
  target_group_arn = aws_lb_target_group.application_lb_target_group.arn
  target_id        = aws_lb.network_lb.arn
  port             = 80
}
