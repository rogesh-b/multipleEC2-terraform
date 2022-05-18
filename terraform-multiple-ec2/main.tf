provider "aws" {
  region = "us-east-1"
}
resource "aws_vpc" "terraformvpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy  = "default"
 tags = {
    Name = "terraform-test-vpc"
  }
}

resource "aws_subnet" "Publicsubnet" {
  vpc_id     = aws_vpc.terraformvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Publicsubnet"
  }
}

resource "aws_subnet" "Privatesubnet" {
  vpc_id     = aws_vpc.terraformvpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Privatesubnet"
  }
}

resource "aws_internet_gateway" "tfigw" {
  vpc_id = aws_vpc.terraformvpc.id

  tags = {
    Name = "tfigw"
  }
}

resource "aws_route_table" "publicRT" {
  vpc_id       = aws_vpc.terraformvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tfigw.id
  }

  tags       = {
    Name     = "publicRT"
  }
}

resource "aws_route_table_association" "publicRT-ass" {
  subnet_id      = aws_subnet.Publicsubnet.id
  route_table_id = aws_route_table.publicRT.id
}

resource "aws_route_table" "privateRT" {
  vpc_id = aws_vpc.terraformvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tfigw.id
  }

  tags = {
    Name = "privateRT"
  }
}

resource "aws_route_table_association" "privateRT_asso" {
  subnet_id = aws_subnet.Privatesubnet.id
  route_table_id = aws_route_table.privateRT.id
}
resource "aws_security_group" "allow_tls" {
  name          = "allow_tls"
  description   = "Allow TLS inbound traffic"
  vpc_id        = aws_vpc.terraformvpc.id
 
 ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }
  ingress {
    description   = "TLS from VPC"
    from_port     = 22
    to_port       = 22
    protocol      = "tcp"
    cidr_blocks   = ["0.0.0.0/0"]
  }
  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks   = ["0.0.0.0/0"]
  }
    tags = {
    Name = "terraform-SG"
  }
  }

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.instances_tags
  public_key = tls_private_key.example.public_key_openssh
}

resource "aws_instance" "my-instance" {
  count                 = var.instance_count
  ami                   = lookup(var.ami,var.aws_region)
  instance_type         = var.instance_type
  key_name              = aws_key_pair.generated_key.key_name
  subnet_id            = aws_subnet.Publicsubnet.id
  security_groups      = [aws_security_group.allow_tls.id]
  
  tags = {
  Name  =  "${var.instances_tags}-${count.index+1}"

  }
}