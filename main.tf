# Create infrastructure for VPC, subnets, and security groups to DynamoDB Ledger
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name            = var.vpc_name
  cidr            = var.cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Name = "${var.vpc_name}"
  }
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true

  tags = {
    Name = "${var.vpc_name}-nat-eip"
  }
}

# Create NAT Gateway and associate the EIP
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = module.vpc.public_subnets[0]  # Use your specific public subnet ID here

  tags = {
    Name = "${var.vpc_name}-nat-gateway"
  }
}

# Create DynamoDB VPC Endpoint
resource "aws_vpc_endpoint" "dynamodb_endpoint" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"

  # Attach endpoint to private subnets
  route_table_ids = module.vpc.private_route_table_ids

  tags = {
    Name = "${var.vpc_name}-dynamodb-endpoint"
  }
}

# Security Group for Public Resources (e.g., API Gateway)
resource "aws_security_group" "public_sg" {
  vpc_id = module.vpc.vpc_id
  name   = "${var.vpc_name}-public-sg"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-public-sg"
  }
}

# Security Group for Private Resources (e.g., Lambda)
resource "aws_security_group" "private_sg" {
  vpc_id = module.vpc.vpc_id
  name   = "${var.vpc_name}-private-sg"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-private-sg"
  }
}

# Create Route Tables for Public and Private Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.vpc.internet_gateway_id
  }

  tags = {
    Name = "${var.vpc_name}-public-route-table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "${var.vpc_name}-private-route-table"
  }
}

# Associate Route Tables with Subnets
resource "aws_route_table_association" "public_association" {
  subnet_id      = module.vpc.public_subnets[0]
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_association" {
  subnet_id      = module.vpc.private_subnets[0]
  route_table_id = aws_route_table.private_route_table.id
}

# Create Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "${var.vpc_name}-internet-gateway"
  }
}
