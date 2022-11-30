data "aws_region" "current" {}

resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = "true"
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.64.0/19"
  availability_zone       = "${data.aws_region.current.name}a"
  map_public_ip_on_launch = true
  tags                    = {
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.96.0/19"
  availability_zone       = "${data.aws_region.current.name}b"
  map_public_ip_on_launch = true
  tags                    = {
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_route_table_association_1" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet_1.id
}

resource "aws_route_table_association" "public_route_table_association_2" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet_2.id
}
