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


  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "springboot-app-asg-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

}

# This resource will trigger an instance refresh when the launch template changes
resource "null_resource" "asg_refresh_trigger" {
  triggers = {
    launch_template_version = aws_launch_template.springboot-app.latest_version
  }

  provisioner "local-exec" {
    command = "aws autoscaling start-instance-refresh --auto-scaling-group-name ${aws_autoscaling_group.springboot-app.name}"
  }

  depends_on = [aws_autoscaling_group.springboot-app]
}