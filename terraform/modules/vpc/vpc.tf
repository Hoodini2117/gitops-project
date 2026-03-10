resource "aws_vpc" "gitops_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "gitops_vpc"
  }
}
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.gitops_vpc.id
  ingress = []
  egress = []
}

resource "aws_subnet" "gitops_subnet_1" {
  vpc_id                  = aws_vpc.gitops_vpc.id
  cidr_block              = var.subnet_1_cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "gitops_subnet_2" {
  vpc_id                  = aws_vpc.gitops_vpc.id
  cidr_block              = var.subnet_2_cidr
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
resource "aws_kms_key" "logs" {
  description         = "CloudWatch logs encryption"
  enable_key_rotation = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },

      {
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.id}.amazonaws.com"    
       }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }

    ]
  })
}
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name = "/aws/vpc/gitops-flow-logs"
  retention_in_days = 365
  kms_key_id = aws_kms_key.logs.arn
}
resource "aws_iam_role" "flow_logs_role" {
  name = "gitops-flow-logs-role"
  assume_role_policy = jsonencode({
     Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn         = aws_iam_role.flow_logs_role.arn
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id = aws_vpc.gitops_vpc.id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.gitops_vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.gitops_vpc.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "subnet_1_assoc" {
  subnet_id      = aws_subnet.gitops_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "subnet_2_assoc" {
  subnet_id      = aws_subnet.gitops_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}