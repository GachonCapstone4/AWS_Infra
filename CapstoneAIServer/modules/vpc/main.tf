resource "aws_vpc" "capstone_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "capstone-vpc"
  }
}
