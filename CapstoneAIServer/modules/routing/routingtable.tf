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
  subnet_id      = var.subnet_id
  route_table_id = aws_route_table.capstone_public_rt.id
}
