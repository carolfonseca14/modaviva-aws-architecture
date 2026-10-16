data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "modaviva" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "modaviva-vpc"
  }
}

resource "aws_internet_gateway" "modaviva" {
  vpc_id = aws_vpc.modaviva.id

  tags = {
    Name = "modaviva-igw"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.modaviva.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "modaviva-subnet-public1-us-east-1a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.modaviva.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "modaviva-subnet-public2-us-east-1b"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.modaviva.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "modaviva-subnet-private1-us-east-1a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.modaviva.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "modaviva-subnet-private2-us-east-1b"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.modaviva.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.modaviva.id
  }

  tags = {
    Name = "modaviva-rtb-public"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.modaviva.id

  tags = {
    Name = "modaviva-rtb-private1-us-east-1a"
  }
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.modaviva.id

  tags = {
    Name = "modaviva-rtb-private2-us-east-1b"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.modaviva.id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private_a.id,
    aws_route_table.private_b.id
  ]

  tags = {
    Name = "modaviva-vpce-s3"
  }
}
