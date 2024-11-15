# we create a VPC, a public subnet (for API Gateway and NAT Gateway), 
# and private subnets (for Lambda functions and secure data handling).

# create infrastructure for VPC, VPC endpoints, and security groups to DynamoDB Ledger
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
# Security group for Lambda function (ensuring access to DynamoDB endpoint)

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

