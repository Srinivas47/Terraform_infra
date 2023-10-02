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
    vpc_id = var.aws_vpc-vpn.id
    cidr_block = var.public_subnet.id
}

# creating the subnets for the web,app,db vpcs
resource "aws_subnet" "web-subnet" {  
    vpc_id = var.aws_vpc_server.id
    cidr_block = var.aws_vpc_server.vpc_id
    availability_zone = "us-east-1c" # Change to your desired availability zone
  tags = {
    Name = "web-subnet"
  }
}
# creating the app-subnets
resource "aws_subnet" "app-subnet" {
  vpc_id     = aws_vpc.web_app_db.id
  cidr_block = "10.1.2.0/24" # Set your private DB subnet IP range
  availability_zone = "us-east-1c" # Change to your desired availability zone
  tags = {
    Name = "app-subnet"
  }
}
# creating the db-subnets
resource "aws_subnet" "db-subnet" {
  vpc_id     = aws_vpc.web_app_db.id
  cidr_block = "10.1.2.0/24" # Set your private DB subnet IP range
  availability_zone = "us-east-1c" # Change to your desired availability zone
  tags = {
    Name = "db-subnet"
  }
}
# creating the igw for the vpn-vpc
resource "aws_internet_gateway" "web-app-db-igw" {
    vpc_id = var.aws_vpc_server.id
  tags = {
    Name = "web-app-db-igw"
  }
}


