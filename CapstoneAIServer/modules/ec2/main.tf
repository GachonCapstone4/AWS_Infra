variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "natvpn_gateway" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = "nat"

  tags = {
    Name = "NatVPN Gateway"
  }
}

resource "aws_eip" "natvpn_eip" {
  instance = aws_instance.natvpn_gateway.id
  vpc      = true

  tags = {
    Name = "capstone-natvpn-eip"
  }
}
