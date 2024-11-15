# Purpose: Define the variables that will be used in the Terraform configuration
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

# VPC variables
variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "A list of availability zones in the region"
  type        = list(string)
}

variable "pvt_subnets" {
  description = "A list of private subnet CIDR blocks"
  type        = list(string)
}

variable "pub_subnets" {
  description = "A list of public subnet CIDR blocks"
  type        = list(string)
}


