
# Create the VPN VPC

variable "aws_vpc-vpn" {
 cidr_block = "10.0.0.0/16" # Set your VPN VPC IP range
}

variable "aws_vpc_server"{
 cidr_block = "10.1.0.0/16" # Set your servers VPC IP range
}

variable "igw" {}
variable "public_subnet" {
    default = "10.1.0.0/24"
}
variable "private_subnet-01" {
    default = "10.2.0.0/24"
}

variable "elstic-IP" {}
variable "public_router" {}
variable "public_router" {}
