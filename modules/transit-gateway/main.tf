resource "aws_ec2_transit_gateway" "this" {
  description                     = "Central hub connecting three VPCs"
  amazon_side_asn                 = 64512
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  auto_accept_shared_attachments  = "disable"

  tags = {
    Name = var.name
  }
}

resource "aws_ec2_transit_gateway_route_table" "this" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id

  tags = {
    Name = "${var.name}-route-table"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  for_each = var.vpcs

  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = each.value.vpc_id
  subnet_ids         = [each.value.subnet_id]

  dns_support                                     = "enable"
  ipv6_support                                   = "disable"
  appliance_mode_support                         = "disable"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name = "${var.name}-${each.key}-attachment"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  for_each = var.vpcs

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
}

resource "aws_ec2_transit_gateway_route" "vpc_routes" {
  for_each = var.vpcs

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
  destination_cidr_block         = each.value.cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this[each.key].id

  depends_on = [
    aws_ec2_transit_gateway_route_table_association.this
  ]
}
