# we create a VPC, a public subnet (for API Gateway and NAT Gateway), 
# and private subnets (for Lambda functions and secure data handling).
# create infrastructure for VPC, VPC endpoints, and security groups to DynamoDB Ledger

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  name               = var.vpc_name
  cidr               = var.cidr
  azs                = var.azs
  private_subnets    = var.pvt_subnets
  public_subnets     = var.pub_subnets
  enable_nat_gateway = true
  single_nat_gateway = true

  # General tags for the VPC and associated resources
  tags = {
    Name = "${var.vpc_name}"
  }

  # Public Subnet Tags (Ensuring uniqueness based on AZ)
  public_subnet_tags = {
    Name = "${var.vpc_name}-pub-subnet"
  }

  # Private Subnet Tags (Ensuring uniqueness based on AZ)
  private_subnet_tags = {
    Name = "${var.vpc_name}-pvt-subnet"
  }

  # Public Route Table Tags
  public_route_table_tags = {
    Name = "${var.vpc_name}-pub-route-table"
  }

  # Private Route Table Tags
  private_route_table_tags = {
    Name = "${var.vpc_name}-pvt-route-table"
  }

  # NAT Gateway Tags
  nat_gateway_tags = {
    Name = "${var.vpc_name}-nat-gateway"
  }

  # Internet Gateway Tags
  igw_tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# Create DynamoDB VPC Endpoint with naming
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

# Security Group for Public Resources (e.g., API Gateway) with naming
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

# Security Group for Private Resources (e.g., Lambda) with naming
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
