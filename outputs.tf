# Purpose: Define the outputs for the module
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_security_group_id" {
  description = "The ID of the security group for public resources (e.g., API Gateway)"
  value       = aws_security_group.public_sg.id
}

output "private_security_group_id" {
  description = "The ID of the security group for private resources (e.g., Lambda)"
  value       = aws_security_group.private_sg.id
}


# DynamoDB VPC endpoint outputs
output "dynamodb_endpoint_id" {
  description = "The ID of the DynamoDB VPC endpoint"
  value       = aws_vpc_endpoint.dynamodb_endpoint.id
}

output "vpc_endpoint_service_name" {
  description = "The service name of the VPC endpoint"
  value       = aws_vpc_endpoint.dynamodb_endpoint.service_name
}
