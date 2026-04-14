resource "aws_route_table" "capstone_public_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.capstone_igw.id
  }

  tags = {
    Name = "capstone-public-rt"
  }
}

resource "aws_route_table_association" "capstone_public_rta" {
  subnet_id      = var.subnet_id.public
  route_table_id = aws_route_table.capstone_public_rt.id
}

resource "aws_route_table" "capstone_ai_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = var.natvpn_eni_id
  }

  tags = {
    Name = "capstone-ai-rt"
  }
}

resource "aws_route_table_association" "capstone_ai_rta" {
  subnet_id      = var.subnet_id.ai
  route_table_id = aws_route_table.capstone_ai_rt.id
}
