output "sg_id" {
  value = {
    natvpn = aws_security_group.natvpn_sg.id
    ai     = aws_security_group.ai_server_sg.id
  }
}
