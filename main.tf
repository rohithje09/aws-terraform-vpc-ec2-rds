provider "aws" {
  region = "us-west-2"
}

# Variables for Security and Flexibility
variable "allowed_ip" {
  description = "Allowed IP address for SSH access"
  default     = "49.43.240.143/32"
}
variable "db_password" {
  description = "Password for the RDS database from tfvars file"
  type        = string
  sensitive   = true
}

variable "key_pair" {
  description = "EC2 Key Pair Name"
  default     = "my-key-pair"
}

# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "MainVPC"
  }
}

# Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.main_vpc.id
  name   = "ec2-security-group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EC2SecurityGroup"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.main_vpc.id
  name   = "rds-security-group"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDSSecurityGroup"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet"
  }
}

# Private Subnet in us-west-2a
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "PrivateSubnetA"
  }
}

# Private Subnet in us-west-2b
resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "PrivateSubnetB"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Create CMK Key
resource "aws_kms_key" "my_key" {
  description             = "KMS CMK for EC2 and RDS Encryption"
  deletion_window_in_days = 10

  tags = {
    Name = "MyKMSKey"
  }
}

resource "aws_kms_alias" "my_key_alias" {
  name          = "alias/my-key-alias"
  target_key_id = aws_kms_key.my_key.id
}

# EC2 Instance
resource "aws_instance" "ec2_instance" {
  ami               = "ami-05134c8ef96964280"
  instance_type     = "t2.micro"
  subnet_id         = aws_subnet.public_subnet.id
  security_groups   = [aws_security_group.ec2_sg.id]
  key_name          = var.key_pair

  root_block_device {
    volume_size = 10
    encrypted   = true
    kms_key_id  = aws_kms_key.my_key.id
  }

  disable_api_termination = true

  tags = {
    Name = "FreeTierEC2"
  }
}

# RDS with Encrypted Storage
resource "aws_db_instance" "rds_instance" {
  allocated_storage    = 20
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  db_name              = "mydatabase"
  username             = "admin"
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  storage_encrypted    = true
  kms_key_id           = aws_kms_key.my_key.arn
  skip_final_snapshot  = true
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "FreeTierRDS"
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private_subnet.id, aws_subnet.private_subnet_b.id]  # Both private subnets

  tags = {
    Name = "RDSSubnetGroup"
  }
}

# Outputs for Easy Access
output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "ec2_instance_id" {
  value = aws_instance.ec2_instance.id
}

output "rds_instance_endpoint" {
  value = aws_db_instance.rds_instance.endpoint
}
