# Define the Launch Template
resource "aws_launch_template" "springboot-app" {
  name_prefix   = "springboot-app-template-"
  image_id      = var.docker_app_ami
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.instance_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "springboot-app-instance"
    }
  }
    user_data = filebase64("./docker_run_petclinic.sh")
}