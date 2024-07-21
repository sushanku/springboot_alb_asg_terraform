# IAM role for EC2 to access ECR
resource "aws_iam_instance_profile" "ecr_access" {
  name = "ecr_access"
  role = aws_iam_role.ec2_ecr_access_role.name
}


resource "aws_iam_role" "ec2_ecr_access_role" {
  name = "ec2-ecr-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for ECR access
resource "aws_iam_role_policy_attachment" "ecr_access_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.ec2_ecr_access_role.name

}