# we create a VPC, a public subnet (for API Gateway and NAT Gateway), 
# and private subnets (for Lambda functions and secure data handling).
# create infrastructure for VPC, VPC endpoints, and security groups to DynamoDB Ledger

# VPC Module
module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  name               = var.vpc_name
  cidr               = var.cidr
  azs                = var.azs
  private_subnets    = var.pvt_subnets
  public_subnets     = var.pub_subnets
  enable_nat_gateway = true
  single_nat_gateway = true

  # Tags for VPC and associated resources
  tags = {
    Name = "${var.vpc_name}"
  }

  public_subnet_tags = {
    Name = "${var.vpc_name}-pub-subnet"
  }

  private_subnet_tags = {
    Name = "${var.vpc_name}-pvt-subnet"
  }

  public_route_table_tags = {
    Name = "${var.vpc_name}-pub-route-table"
  }

  private_route_table_tags = {
    Name = "${var.vpc_name}-pvt-route-table"
  }

  nat_gateway_tags = {
    Name = "${var.vpc_name}-nat-gateway"
  }

  igw_tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# DynamoDB VPC Endpoint
resource "aws_vpc_endpoint" "dynamodb_endpoint" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.private_route_table_ids
  tags = {
    Name = "${var.vpc_name}-dynamodb-endpoint"
  }
}

# Secrets Manager VPC Endpoint
resource "aws_vpc_endpoint" "secrets_manager_endpoint" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type = "Interface"
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.private_sg.id]
  tags = {
    Name = "${var.vpc_name}-secrets-manager-endpoint"
  }
}

# KMS VPC Endpoint
resource "aws_vpc_endpoint" "kms_endpoint" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.kms"
  vpc_endpoint_type = "Interface"
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.private_sg.id]
  tags = {
    Name = "${var.vpc_name}-kms-endpoint"
  }
}

# CloudWatch VPC Endpoint
resource "aws_vpc_endpoint" "cloudwatch_endpoint" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.monitoring"
  vpc_endpoint_type = "Interface"
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.private_sg.id]
  tags = {
    Name = "${var.vpc_name}-cloudwatch-endpoint"
  }
}

# STS VPC Endpoint
resource "aws_vpc_endpoint" "sts_endpoint" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.sts"
  vpc_endpoint_type = "Interface"
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.private_sg.id]
  tags = {
    Name = "${var.vpc_name}-sts-endpoint"
  }
}

# # SQS VPC Endpoint (Optional)
# resource "aws_vpc_endpoint" "sqs_endpoint" {
#   vpc_id            = module.vpc.vpc_id
#   service_name      = "com.amazonaws.${var.aws_region}.sqs"
#   vpc_endpoint_type = "Interface"
#   subnet_ids        = module.vpc.private_subnet_ids
#   security_group_ids = [aws_security_group.private_sg.id]
#   tags = {
#     Name = "${var.vpc_name}-sqs-endpoint"
#   }
# }

# Security Group for Public Resources
resource "aws_security_group" "public_sg" {
  vpc_id = module.vpc.vpc_id
  name   = "${var.vpc_name}-pub-sg"
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
    Name = "${var.vpc_name}-pub-sg"
  }
}

# Security Group for Private Resources
resource "aws_security_group" "private_sg" {
  vpc_id = module.vpc.vpc_id
  name   = "${var.vpc_name}-pvt-sg"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.vpc_name}-pvt-sg"
  }
}
