

#******************Networking Resources**********************
data "aws_availability_zones" "available" {}

resource "aws_vpc" "my_vpc" {
  cidr_block            = var.vpc_cidr
  enable_dns_hostnames  = true  

  tags = {
    Name = "my_vpc"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_igw"
  }
}

resource "aws_route_table" "my_public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "my_public_rt"
  }
}

resource "aws_subnet" "my_public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_cidrs
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "my_public_subnet"
  }  
}

resource "aws_route_table_association" "my_public_rt_assoc" {
  subnet_id      = aws_subnet.my_public_subnet.id
  route_table_id = aws_route_table.my_public_rt.id
}

resource "aws_subnet" "my_private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_cidrs
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "my_private_subnet"
  }
}

resource "aws_route_table" "my_private_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_private_rt"
}
}

resource "aws_route_table_association" "my_private_rt_assoc" {
  subnet_id      = aws_subnet.my_private_subnet.id
  route_table_id = aws_route_table.my_private_route_table.id
}

resource "aws_security_group" "my_public_sg" {
  name        = "my_public_sg"
  description = "for ssh and http"
  vpc_id      = aws_vpc.my_vpc.id
 
  #For SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.accessip
  }
    
  #For HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.accessip
  }

  #HTTP
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}