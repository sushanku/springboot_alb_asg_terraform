# Create the Application Load Balancer (in public subnets)
resource "aws_lb" "springboot-app" {
  name               = "springboot-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]  # Use public subnets for the ALB
}

# Create a target group for the ALB
resource "aws_lb_target_group" "springboot-app" {
  name     = "springboot-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.springboot-app.id

  health_check {
    path                = "/"  # Assuming you have a /health endpoint
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"  # Success codes
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = true
  }
  
}

# Create a listener for the ALB
resource "aws_lb_listener" "springboot-app" {
  load_balancer_arn = aws_lb.springboot-app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.springboot-app.arn
  }
}