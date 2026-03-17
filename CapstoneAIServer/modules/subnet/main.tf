resource "aws_subnet" "capstone_public_subnet" {
  vpc_id                  = var.vpc_id
  cidr_block              = "172.16.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "capstone-public-subnet"
  }
}

resource "aws_subnet" "capstone_ai_subnet" {
  vpc_id                  = var.vpc_id
  cidr_block              = "172.16.2.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "capstone-ai-subnet"
  }
}
