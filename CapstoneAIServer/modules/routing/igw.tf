resource "aws_internet_gateway" "capstone_igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "capstone-igw"
  }
}
