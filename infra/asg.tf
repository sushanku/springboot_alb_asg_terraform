# Create the Auto Scaling Group
resource "aws_autoscaling_group" "springboot-app" {
  name                = "springboot-app-asg"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 1
  target_group_arns   = [aws_lb_target_group.springboot-app.arn]
  vpc_zone_identifier = [aws_subnet.private1.id, aws_subnet.private2.id]  # Use private subnets

  launch_template {
    id      = aws_launch_template.springboot-app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "springboot-app-asg-instance"
    propagate_at_launch = true
  }
}