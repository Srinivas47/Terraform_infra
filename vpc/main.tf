# creating the vpn-vpc connection 
resource "aws_vpc" "vpn-vpc" {
  cidr_block = var.aws_vpc-vpn.id
  enable_dns_support = true
  enable_dns_hostnames = true
}

# creating the vpn-web,app,db connection
resource "aws_vpc" "servers-vpc" {
 cidr_block = var.aws_vpc_server.id 
  enable_dns_support = false
  enable_dns_hostnames = false 
}

#creating the subnets for the vpn-vpc
resource "aws_subnet" "vpn-subnet" {
    cidr_block = var.public_subnet.id
}

# creating the subnets for the web,app,db vpcs
resource "aws_subnet" "web-s" {
  
}