output "subnet_id" {
  value = {
    public = aws_subnet.capstone_public_subnet.id
    ai     = aws_subnet.capstone_ai_subnet.id
  }
}
