# Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true


  tags = {
    Name = "k8s-project-vpc"
  }
}

# internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

# public subnet(2Azs for realism)
resource "aws_subnet" "public-1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public-2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "public-subnet-2"
  }
}

# route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-route-table"
  }
}

# route table association
resource "aws_route_table_association" "public-1-association" {
  subnet_id      = aws_subnet.public-1.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public-2-association" {
  subnet_id      = aws_subnet.public-2.id
  route_table_id = aws_route_table.public.id
}

# security group
resource "aws_security_group" "k8s_sg" {
  name        = "k8s-platform-sg"
  description = "Security group for Kubernetes cluster"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["102.89.45.213/32"]
  }

  ingress {
    description = "Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["102.89.45.213/32"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Internal cluster communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-platform-sg"
  }

  ingress {
    description = "Kubernetes NodePort range"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ssh key pair
resource "aws_key_pair" "k8s_key" {
  key_name   = "k8s-platform-key"
  public_key = file("~/.ssh/k8s-platform-key.pub")
}

# control plane instances and worker nodes
resource "aws_instance" "control_plane" {
  ami                         = "ami-09d0c9a85bf1b9ea7"
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.public-1.id
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  key_name                    = aws_key_pair.k8s_key.key_name
  associate_public_ip_address = true

  tags = {
    Name = "k8s-control-plane"
  }
}

resource "aws_instance" "worker_node" {
  ami                         = "ami-09d0c9a85bf1b9ea7"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public-2.id
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  key_name                    = aws_key_pair.k8s_key.key_name
  associate_public_ip_address = true

  tags = {
    Name = "k8s-worker-node"
  }
}