# AWS Virtual Private Network
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
}

# AWS Internet Gateway
resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.vpc.id
}

# Fetch AZs in the current region
data "aws_availability_zones" "available" {}

# Public subnets
resource "aws_subnet" "public_subnets" {
  count = var.az_count
  vpc_id = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, local.az_newbits, count.index)
  map_public_ip_on_launch = true
}

# Elastic IPs for NAT
resource "aws_eip" "nat_eip" {
  count = var.az_count
  vpc = true
}

# NAT gateway
resource "aws_nat_gateway" "nat_gw" {
  count = var.az_count
  depends_on = [aws_internet_gateway.internet_gw]
  allocation_id = element(aws_eip.nat_eip.*.id, count.index)
  subnet_id = element(aws_subnet.public_subnets.*.id, count.index)
}

# Public route table
resource "aws_route_table" "public_subnets_route_table" {
  count = var.az_count
  vpc_id = aws_vpc.vpc.id
}

# Public route to access internet
resource "aws_route" "public_internet_route" {
  count = var.az_count
  depends_on = [aws_internet_gateway.internet_gw, aws_route_table.public_subnets_route_table]
  route_table_id = element(aws_route_table.public_subnets_route_table.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.internet_gw.id
}

# Association of public route table to subnets
resource "aws_route_table_association" "public_internet_route_table_associations" {
  count = var.az_count
  subnet_id = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = element(aws_route_table.public_subnets_route_table.*.id, count.index)
}

# Private subnets
resource "aws_subnet" "private_subnets" {
  count = var.az_count
  vpc_id = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, local.az_newbits, var.az_count + count.index)
  map_public_ip_on_launch = false
}

# Private route table
resource "aws_route_table" "private_subnets_route_table" {
  count = var.az_count
  vpc_id = aws_vpc.vpc.id
}

# Private route to access the internet
resource "aws_route" "private_internet_route" {
  count = var.az_count
  depends_on = [aws_internet_gateway.internet_gw, aws_route_table.private_subnets_route_table]
  route_table_id = element(aws_route_table.private_subnets_route_table.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = element(aws_nat_gateway.nat_gw.*.id, count.index)
}

# Association of private route table to subnets
resource "aws_route_table_association" "private_internet_route_table_associations" {
  count = var.az_count
  subnet_id = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = element(aws_route_table.private_subnets_route_table.*.id, count.index)
}

# Create security group for VPC endpoints
resource "aws_security_group" "vpc_endpoint_sg" {
  name = "fargate-test-vpc-endpoint-sg"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }
}

# Create a PrivateLink interface endpoints for ECR
resource "aws_vpc_endpoint" "ecr" {
  vpc_id = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = true
}

# Associate subnet with ECR PrivateLink interface endpoint
resource "aws_vpc_endpoint_subnet_association" "private_subnet_ecr_subnet_assoc" {
  count = var.az_count
  vpc_endpoint_id = aws_vpc_endpoint.ecr.id
  subnet_id = element(aws_subnet.private_subnets.*.id, count.index)
}

# ECR API is also required for version 1.4.0
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = true
}

# Associate subnet with ECR API PrivateLink interface endpoint
resource "aws_vpc_endpoint_subnet_association" "private_subnet_ecr_api_subnet_assoc" {
  count = var.az_count
  vpc_endpoint_id = aws_vpc_endpoint.ecr_api.id
  subnet_id = element(aws_subnet.private_subnets.*.id, count.index)
}

# Create a PrivateLink interface endpoint for S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
}

# Associate route table with S3 PrivateLink interface endpoint
resource "aws_vpc_endpoint_route_table_association" "private_subnet_s3_route_table_assoc" {
  count = var.az_count
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id = element(aws_route_table.private_subnets_route_table.*.id, count.index)
}

# Create a PrivateLink interface endpoint for logs
resource "aws_vpc_endpoint" "logs" {
  vpc_id = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = true
}

# Associate subnet with the logs PrivateLink interface endpoint
resource "aws_vpc_endpoint_subnet_association" "private_subnet_logs_subnet_assoc" {
  count = var.az_count
  vpc_endpoint_id = aws_vpc_endpoint.logs.id
  subnet_id = element(aws_subnet.private_subnets.*.id, count.index)
}
