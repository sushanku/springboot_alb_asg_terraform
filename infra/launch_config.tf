resource "aws_instance" "bastion" {
  ami                         = var.baston_ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.terraform-lab.key_name
  iam_instance_profile        = aws_iam_instance_profile.session-manager.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.ec2.id]
  subnet_id                   = aws_subnet.public-subnet-1.id
  tags = {
    Name = "Bastion"
  }
}


resource "aws_launch_template" "ec2" {
  name_prefix                 = "${var.ec2_instance_name}-instances-lc"
  image_id                    = var.docker_app_ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.terraform-lab.key_name

  
  iam_instance_profile         {
    name                      = aws_iam_instance_profile.session-manager.id
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [aws_security_group.ec2.id]
  }

  user_data = filebase64("${path.module}/docker_run_petclinic.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.ec2_instance_name}-instance"
      # Environment = var.environment
    }
  }

  depends_on = [aws_nat_gateway.terraform-lab-ngw]

  lifecycle {
    create_before_destroy = true
  }
}
