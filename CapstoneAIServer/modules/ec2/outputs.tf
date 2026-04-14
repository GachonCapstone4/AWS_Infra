output "ec2_id" {
  value = {
    natvpn = aws_instance.natvpn_gateway.id
    ai     = aws_instance.ai_server.id
  }
}

output "natvpn_instance_id" {
  value = aws_instance.natvpn_gateway.id
}

output "natvpn_eni_id" {
  value = aws_instance.natvpn_gateway.primary_network_interface_id
}
