variable "subnet_id" {
  type = object({
    public = string
    ai     = string
  })
}

variable "security_group_id" {
  type = object({
    natvpn = string
    ai     = string
  })
}

data "aws_ami" "ubuntu_amd64" {
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

data "aws_ami" "ubuntu_arm64" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "natvpn_gateway" {
  ami                    = data.aws_ami.ubuntu_amd64.id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id.public
  vpc_security_group_ids = [var.security_group_id.natvpn]
  key_name               = "nat"
  private_ip             = "172.16.1.10"
  source_dest_check      = false

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

resource "aws_instance" "ai_server" {
  ami                    = data.aws_ami.ubuntu_arm64.id
  instance_type          = "t4g.medium"
  subnet_id              = var.subnet_id.ai
  vpc_security_group_ids = [var.security_group_id.ai]
  key_name               = "nat"
  private_ip             = "172.16.2.10"
  root_block_device {
    volume_size = 10
    volume_type = "gp2"
  }

  tags = {
    Name = "AIserver"
  }
}
