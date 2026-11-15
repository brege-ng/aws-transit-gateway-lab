output "transit_gateway_id" {
  description = "ID of the central AWS Transit Gateway."
  value       = module.transit_gateway.transit_gateway_id
}

output "transit_gateway_route_table_id" {
  description = "ID of the Transit Gateway route table."
  value       = module.transit_gateway.transit_gateway_route_table_id
}

output "vpc_ids" {
  description = "IDs of the three VPCs."
  value = {
    vpc1 = module.vpc1.vpc_id
    vpc2 = module.vpc2.vpc_id
    vpc3 = module.vpc3.vpc_id
  }
}

output "ec2_private_ips" {
  description = "Private IP addresses of the EC2 instances."
  value = {
    vpc1 = module.vpc1.instance_private_ip
    vpc2 = module.vpc2.instance_private_ip
    vpc3 = module.vpc3.instance_private_ip
  }
}

output "vpc_route_table_ids" {
  description = "Route table IDs containing routes to the other VPCs."
  value = {
    vpc1 = module.vpc1.route_table_id
    vpc2 = module.vpc2.route_table_id
    vpc3 = module.vpc3.route_table_id
  }
}
