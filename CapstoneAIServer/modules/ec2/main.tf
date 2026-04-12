variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "natvpn_gateway" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = "nat"
  private_ip             = "172.16.1.10"

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
