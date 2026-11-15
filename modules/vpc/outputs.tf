output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "subnet_id" {
  description = "ID of the subnet used by the EC2 and TGW attachment."
  value       = aws_subnet.this.id
}

output "route_table_id" {
  description = "ID of the VPC route table."
  value       = aws_route_table.this.id
}

output "security_group_id" {
  description = "ID of the EC2 security group."
  value       = aws_security_group.this.id
}

output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.this.id
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance."
  value       = aws_instance.this.private_ip
}
