provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "app_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "app_vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "app-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "devops_sg" {
  name        = "devops_sg"
  description = "Allow SSH and HTTP access"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP (App)"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins Web UI"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops_sg"
  }
}

resource "aws_instance" "jenkins_server" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  key_name      = "sunday"
  subnet_id     = aws_subnet.public_subnet_1.id
  associate_public_ip_address = true
  security_groups = [aws_security_group.devops_sg.name]
  tags = {
    Name = "jenkins-server"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum groupinstall -y "Development Tools"
              sudo yum install -y gcc openssl-devel bzip2-devel libffi-devel wget make
              cd /usr/src
              sudo wget https://www.python.org/ftp/python/3.8.18/Python-3.8.18.tgz
              sudo tar xzf Python-3.8.18.tgz
              cd Python-3.8.18
              sudo ./configure --enable-optimizations
              sudo make altinstall
              EOF
}


resource "aws_instance" "app_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet_2.id
  associate_public_ip_address = true
  key_name                    = var.key_name
  vpc_security_group_ids = [aws_security_group.devops_sg.id]


  tags = {
    Name = "app-server"
  }
}
