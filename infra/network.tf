# this network.tf consists of VPC, IG, Nat Gateway, Public/Private Subnets, Route Table and its associations
# VPC
resource "aws_vpc" "springboot-app" {
  cidr_block           = var.vpc
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "springboot-app-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "springboot-app" {
  vpc_id = aws_vpc.springboot-app.id

  tags = {
    Name = "springboot-app-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.springboot-app.id
  cidr_block              = var.public_subnet_1
  availability_zone       = "us-east-1a" # Replace with your desired AZ
  map_public_ip_on_launch = true

  tags = {
    Name = "springboot-app-public-subnet-1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.springboot-app.id
  cidr_block              = var.public_subnet_2
  availability_zone       = "us-east-1b" # Replace with your desired AZ
  map_public_ip_on_launch = true

  tags = {
    Name = "springboot-app-public-subnet-2"
  }
}

# Private Subnets
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.springboot-app.id
  cidr_block        = var.private_subnet_1
  availability_zone = "us-east-1a" # Replace with your desired AZ

  tags = {
    Name = "springboot-app-private-subnet-1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.springboot-app.id
  cidr_block        = var.private_subnet_2
  availability_zone = "us-east-1b" # Replace with your desired AZ

  tags = {
    Name = "springboot-app-private-subnet-2"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  #   domain = "vpc"

  tags = {
    Name = "springboot-app-nat-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "springboot-app" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "springboot-app-nat-gateway"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.springboot-app.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.springboot-app.id
  }

  tags = {
    Name = "springboot-app-public-route-table"
  }
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.springboot-app.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.springboot-app.id
  }

  tags = {
    Name = "springboot-app-private-route-table"
  }
}

# Route Table Associations
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}
