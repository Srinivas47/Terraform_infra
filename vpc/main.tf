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


# Create a NAT Gateway in the public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id    = var.aws_vpc_server.id
  tags = {
    Name = "nat-gateway"
  }
}

# create a route table for the vpn subnet
resource "aws_route_table" "vpn-rotue" {
  vpc_id = var.aws_vpc-vpn.id
}



# Create a default route to the NAT Gateway for private subnets
resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Associate the private subnets with the private route table
resource "aws_route_table_association" "private_app" {
  subnet_id      = aws_subnet.private_app.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_db" {
  subnet_id      = aws_subnet.private_db.id
  route_table_id = aws_route_table.private.id
}

# Define security groups for Web, App, and DB servers (example)
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Security Group for Web Server"
  
  # Allow incoming traffic from your IP address only (HTTP/HTTPS)
  ingress {
    from_port   = 80
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP_ADDRESS/32"] # Replace with your IP address
  }
}

resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Security Group for App Server"
  
  # Allow incoming traffic from Web server only
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }
}

resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Security Group for DB Server"
  
  # Allow incoming traffic from App server only (Database port)
  ingress {
    from_port   = 3306 # MySQL port, adjust as needed
    to_port     = 3306 # MySQL port, adjust as needed
    protocol    = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }
}

# Create EC2 instances for Web, App, and DB servers (example)
resource "aws_instance" "web_server" {
  ami           = "ami-xxxxxxxxxxxx" # Specify your Web server AMI ID
  instance_type = "t2.micro" # Choose an appropriate instance type
  subnet_id     = aws_subnet.public.id
  security_groups = [aws_security_group.web_sg.id]
  # Add other configuration options as needed
  tags = {
    Name = "web-server"
  }
}

resource "aws_instance" "app_server" {
  ami           = "ami-xxxxxxxxxxxx" # Specify your App server AMI ID
  instance_type = "t2.micro" # Choose an appropriate instance type
  subnet_id     = aws_subnet.private_app.id
  security_groups = [aws_security_group.app_sg.id]
  # Add other configuration options as needed
  tags = {
    Name = "app-server"
  }
}

resource "aws_instance" "db_server" {
  ami           = "ami-xxxxxxxxxxxx" # Specify your DB server AMI ID
  instance_type = "t2.micro" # Choose an appropriate instance type
  subnet_id     = aws_subnet.private_db.id
  security_groups = [aws_security_group.db_sg.id]
  # Add other configuration options as needed
  tags = {
    Name = "db-server"
  }
}

# Create VPC peering connection between VPN VPC and Web-App-DB VPC
resource "aws_vpc_peering_connection" "peering" {
  peer_vpc_id          = aws_vpc.vpn.id
  vpc_id               = aws_vpc.web_app_db.id
  auto_accept          = true # You can set this to false if manual acceptance is required
  tags = {
    Name = "vpc-peering"
  }
}


