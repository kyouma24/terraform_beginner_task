# VPC
resource "aws_vpc" "testvpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "testvpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.testvpc.id

  tags = {
    Name = "test-gw"
  }
}

# Custom Route Table
resource "aws_route_table" "testroute-table" {
  vpc_id = aws_vpc.testvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "test-rt"
  }
}

# Subnet
resource "aws_subnet" "test-subnet" {
  vpc_id            = aws_vpc.testvpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone

  tags = {
    Name = "test-subnet"
  }
}

# Associate subnet with Route Table
resource "aws_route_table_association" "rt_association" {
  subnet_id      = aws_subnet.test-subnet.id
  route_table_id = aws_route_table.testroute-table.id
}

# Keypair
resource "aws_key_pair" "tfkey" {
  key_name   = var.aws_key_pair
  public_key = tls_private_key.rsa.public_key_openssh
}

# tls private key
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# save private key to ubuntu instance
resource "local_file" "tfkey" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "tfkey"
}

# Ubuntu instance
resource "aws_instance" "my_instance" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name = var.aws_key_pair
  associate_public_ip_address = true
  availability_zone = var.availability_zone
  vpc_security_group_ids = [aws_security_group.test_sg.id]
  subnet_id = aws_subnet.test-subnet.id

  tags = {
    Name = "test-ubuntu"
  }
}

# for nginx on ubuntu instance
resource "null_resource" "nginx"{
  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install nginx -y ",
      "sudo service nginx start",
      
    ]
  connection{
        type = "ssh"
        user = "ubuntu"
        private_key = tls_private_key.rsa.private_key_pem
        host = aws_instance.my_instance.public_ip
    }
  } 
}

# EIP
resource "aws_eip" "my_eip" {
  instance = aws_instance.my_instance.id
  domain   = "vpc"
 
  tags = {
    Name = "test-eip"
  }
}

# Creating an EBS Volume
resource "aws_ebs_volume" "tf_ebs" {
  availability_zone = var.availability_zone
  size              = 8
  encrypted = true
  type = "gp2"
  kms_key_id = aws_kms_key.tf-key.arn

  tags = {
    Name = "tf-ebs"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.tf_ebs.id
  instance_id = aws_instance.my_instance.id
}

# KMS key for EBS volume encryption
resource "aws_kms_key" "tf-key" {
  description             = "KMS key for EBS volume encryption"
  deletion_window_in_days = 10
}

# Alias for KMS key
resource "aws_kms_alias" "a" {
  name          = "alias/tf-key"
  target_key_id = aws_kms_key.tf-key.key_id
}

resource "aws_security_group" "test_sg" {
  name        = "test_sg"
  vpc_id      = aws_vpc.testvpc.id

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    for_each = var.egress_ports
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}