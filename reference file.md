






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

# Create a route
