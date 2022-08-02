terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_vpc" "Main" {
  cidr_block       = "10.0.0.0/24"
  instance_tenancy = "default"
  tags = {
    name = "Main"
  }
}
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.Main.id
}
resource "aws_subnet" "public_A" {
  vpc_id     = aws_vpc.Main.id
  cidr_block = "10.0.0.0/26"
  map_public_ip_on_launch = true
  tags = {
    name = "public_A"
  }
}
resource "aws_subnet" "public_B" {
  vpc_id     = aws_vpc.Main.id
  cidr_block = "10.0.0.64/26"
  map_public_ip_on_launch = true
  tags = {
    name = "public_B"
  }
}
resource "aws_subnet" "private_C" {
  vpc_id     = aws_vpc.Main.id
  cidr_block = "10.0.0.128/26"
  tags = {
    name = "private_C"
  }
}
resource "aws_subnet" "private_D" {
  vpc_id     = aws_vpc.Main.id
  cidr_block = "10.0.0.192/26"
  tags = {
    name = "private_D"
  }
}
resource "aws_route_table" "PublicRT" {
  vpc_id = aws_vpc.Main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    name = "PublicRT"
  }
}
resource "aws_route_table" "PrivateRT_C" {
  vpc_id = aws_vpc.Main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATgw_1.id
  }
  tags = {
    name = "PrivateRT_C"
  }
}
resource "aws_route_table" "PrivateRT_D" {
  vpc_id = aws_vpc.Main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATgw_2.id
  }
  tags = {
    name = "PrivateRT_D"
  }
}
resource "aws_route_table_association" "PublicRTassociation_A" {
  subnet_id      = aws_subnet.public_A.id
  route_table_id = aws_route_table.PublicRT.id
}
resource "aws_route_table_association" "PublicRTassociation_B" {
  subnet_id      = aws_subnet.public_B.id
  route_table_id = aws_route_table.PublicRT.id
}
resource "aws_route_table_association" "PrivateRTassociation_C" {
  subnet_id      = aws_subnet.private_C.id
  route_table_id = aws_route_table.PrivateRT_C.id
}
resource "aws_route_table_association" "PrivateRTassociation_D" {
  subnet_id      = aws_subnet.private_D.id
  route_table_id = aws_route_table.PrivateRT_D.id
}
resource "aws_eip" "nateIP_1" {
  vpc = true
}
resource "aws_nat_gateway" "NATgw_1" {
  allocation_id = aws_eip.nateIP_1.id
  subnet_id     = aws_subnet.public_A.id
}
resource "aws_eip" "nateIP_2" {
  vpc = true
}
resource "aws_nat_gateway" "NATgw_2" {
  allocation_id = aws_eip.nateIP_2.id
  subnet_id     = aws_subnet.public_B.id
}
