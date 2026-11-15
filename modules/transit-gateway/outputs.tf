output "transit_gateway_id" {
  description = "ID of the Transit Gateway."
  value       = aws_ec2_transit_gateway.this.id
}

output "transit_gateway_route_table_id" {
  description = "ID of the Transit Gateway route table."
  value       = aws_ec2_transit_gateway_route_table.this.id
}

output "attachment_ids" {
  description = "Transit Gateway attachment IDs, keyed by VPC name."
  value = {
    for name, attachment in aws_ec2_transit_gateway_vpc_attachment.this :
    name => attachment.id
  }
}
