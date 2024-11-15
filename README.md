# Payment Gateway Infrastructure

This project sets up the necessary AWS infrastructure to support a payment gateway system. The infrastructure includes a VPC, public and private subnets, NAT gateway, security groups, and a DynamoDB VPC endpoint. This is a critical part of the architecture for securely processing payment data, ensuring that Lambda functions can access DynamoDB and other services securely.

## Overview

This Terraform configuration deploys the following infrastructure:

- **VPC (Virtual Private Cloud)**: Contains all network resources for the payment gateway.
- **Public Subnet**: For public-facing services like API Gateway and NAT Gateway.
- **Private Subnet**: For Lambda functions and secure data handling.
- **NAT Gateway**: For outbound internet access for resources in private subnets.
- **Security Groups**: To control access to resources in the public and private subnets.
- **DynamoDB VPC Endpoint**: To securely access DynamoDB from within the VPC without routing traffic over the public internet.

## Architecture

The infrastructure consists of the following components:

- **VPC**: A network container that includes subnets, route tables, and gateways.
- **Subnets**:
  - **Public Subnet**: For services like API Gateway and NAT Gateway.
  - **Private Subnet**: For Lambda functions, where sensitive data processing and DynamoDB interactions occur.
- **NAT Gateway**: Allows resources in the private subnet to access the internet while remaining isolated from direct internet access.
- **Security Groups**: Ensure that only authorized services can communicate within the VPC.
  - **Public Security Group**: For API Gateway to accept inbound traffic from the internet.
  - **Private Security Group**: For Lambda functions to interact with resources like DynamoDB.
- **DynamoDB VPC Endpoint**: Allows secure, private access to DynamoDB.

## Resources Created

- **VPC**:
  - Name: `${var.vpc_name}`
  - CIDR block: `${var.cidr}`
  - Availability Zones: `${var.azs}`
- **Subnets**:
  - Public Subnets: `${var.public_subnets}`
  - Private Subnets: `${var.private_subnets}`
- **NAT Gateway**:
  - A single NAT Gateway for internet access from private subnets.
- **Security Groups**:
  - **Public Security Group**: Allows inbound traffic on port 443 (HTTPS) from any IP (`0.0.0.0/0`).
  - **Private Security Group**: Allows outbound traffic to any destination (`0.0.0.0/0`).
- **DynamoDB VPC Endpoint**:
  - Connects the VPC securely to DynamoDB.
  - Ensures that DynamoDB access is routed via private IPs within the VPC.

## Prerequisites

- **Terraform**: Ensure that Terraform is installed on your machine. You can download it from the [Terraform website](https://www.terraform.io/downloads).
- **AWS Account**: You must have access to an AWS account with the necessary permissions to create VPCs, subnets, and other networking resources.
- **AWS CLI**: Install and configure the AWS CLI with the correct credentials.

## Configuration

### Variables

The following variables must be defined in a `.tfvars` file or directly in your Terraform configuration:

- `vpc_name`: The name of the VPC.
- `cidr`: The CIDR block for the VPC.
- `azs`: List of availability zones for the VPC.
- `private_subnets`: List of CIDR blocks for private subnets.
- `public_subnets`: List of CIDR blocks for public subnets.
- `aws_region`: The AWS region where the infrastructure will be deployed.

Example `terraform-dev.tfvars`:

```hcl
vpc_name        = "PaymentGateway"
cidr            = "10.0.0.0/16"
azs             = ["ca-central-1a", "ca-central-1b"]
private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
aws_region        = "ca-central-1"
