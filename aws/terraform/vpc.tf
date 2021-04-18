resource "aws_vpc" "AppVPC" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.AppVPC.id

  tags = {
    Name = "internet-gw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.AppVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "r-public"
  }
}

resource "aws_route_table_association" "public1" {
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.aws-subnet-public-1.id
}

resource "aws_route_table_association" "public2" {
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.aws-subnet-public-2.id
}


resource "aws_subnet" "aws-subnet-public-1" {
  vpc_id            = aws_vpc.AppVPC.id
  cidr_block        = var.vpc_cidr_public_1
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "public-1"
  }
}

resource "aws_subnet" "aws-subnet-public-2" {
  vpc_id            = aws_vpc.AppVPC.id
  cidr_block        = var.vpc_cidr_public_2
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "public-2"
  }
}

resource "aws_db_subnet_group" "mysql_group" {
  name       = "dbsubngroup"
  subnet_ids = [aws_subnet.aws-subnet-public-1.id, aws_subnet.aws-subnet-public-2.id]

  tags = {
    Name = "dbsubnetGroup"
  }
}