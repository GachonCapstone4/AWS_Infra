output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnet_ids" {
  value = module.subnet.subnet_id
}

output "security_group_ids" {
  value = module.security_group.sg_id
}

output "ec2_instances" {
  value = module.ec2.ec2_id
}

output "natvpn_gateway" {
  value = {
    instance_id = module.ec2.natvpn_instance_id
  }
}
