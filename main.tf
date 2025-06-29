	provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.rt.id
}
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Allow SSH access"
  vpc_id      = aws_vpc.main.id

ingress {
  description = "SSH"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_key_pair" "generated" {
  key_name   = "k3s-key"
  public_key = file("${path.module}/k3s-key.pub")
}


resource "aws_instance" "bastion" {
  ami = "ami-0c55825bb0a77f4cf"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name = aws_key_pair.generated.key_name


  tags = {
    Name = "bastion-host"
  }
}
resource "aws_instance" "worker" {
  ami           = "ami-0c55825bb0a77f4cf"   # тот же Amazon Linux 2 во Франкфурте
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name      = aws_key_pair.generated.key_name

  user_data = <<-EOF
    #!/bin/bash
    curl -sfL https://get.k3s.io | \
      K3S_URL=https://10.0.1.198:6443 \
      K3S_TOKEN="K107b0b6630564c1e40708f47f1971ef220e4b78125245580c5e151031ae5bde858::server:6ece6b7ce9699d394bfe4e06d67d6f7d" \
      INSTALL_K3S_SKIP_SELINUX_RPM=true \
      sh -s - agent
  EOF

  tags = { Name = "k3s-worker" }
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}



