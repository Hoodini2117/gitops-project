resource "aws_vpc" "gitops_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "gitops_vpc"
  }
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