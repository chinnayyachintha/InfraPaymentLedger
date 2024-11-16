# This file contains the variables that are used in the terraform code.
aws_region = "ca-central-1"

# VPC variables
vpc_name        = "PaymentGateway"
cidr            = "10.0.0.0/16"
azs             = ["ca-central-1a"]
pvt_subnets = ["10.0.1.0/24"]
pub_subnets  = ["10.0.101.0/24"]