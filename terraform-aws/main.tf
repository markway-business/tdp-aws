# Criar a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

# Criar o Internet Gateway e associá-lo à VPC
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# Criar a tabela de rotas pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Criar a subnet pública
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# Associar a tabela de rotas pública à subnet pública
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Criar a subnet privada
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet"
  }
}

# Criar o security group para os nós Master e Data Nodes
resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "private-sg"
  }
}

# Criar as instâncias Master na subnet pública
resource "aws_instance" "master" {
  count                   = 1
  ami                     = var.ami_id
  instance_type           = "c5.xlarge"
  subnet_id               = aws_subnet.public.id
  key_name                = var.key_name
  vpc_security_group_ids  = [aws_security_group.private_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 50
  }

  tags = {
    Name = "master${count.index + 1}.markway.com.br"
    Environment = var.tag_environment
  }
}

# Criar as instâncias Data na subnet pública
resource "aws_instance" "data" {
  count                   = 0
  ami                     = var.ami_id
  instance_type           = "c5.xlarge"
  subnet_id               = aws_subnet.public.id
  key_name                = var.key_name
  vpc_security_group_ids  = [aws_security_group.private_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 30
  }

  ebs_block_device {
    device_name = "/dev/sdh"
    volume_size = 200
  }

  tags = {
    Name = "data${count.index + 1}.markway.com.br"
    Environment = var.tag_environment
  }

  user_data = <<-EOF
              #!/bin/bash
              mkfs.ext4 /dev/sdh
              mkdir -p /dados01
              mount /dev/sdh /dados01
              echo "/dev/sdh /dados01 ext4 defaults,nofail 0 2" >> /etc/fstab
              EOF
}

output "private_ips" {
  value = concat(
    aws_instance.master[*].private_ip,
    aws_instance.data[*].private_ip
  )
}

output "public_ips" {
  value = concat(
    aws_instance.master[*].public_ip,
    aws_instance.data[*].public_ip
  )
}

output "master_private_ips" {
  value = aws_instance.master[*].private_ip
}

output "data_private_ips" {
  value = aws_instance.data[*].private_ip
}

output "master_public_ips" {
  value = aws_instance.master[*].public_ip
}

output "data_public_ips" {
  value = aws_instance.data[*].public_ip
}
