module "vpc1" {
  source = "./modules/vpc"

  name              = "vpc-1"
  vpc_cidr          = var.vpc1_cidr
  subnet_cidr       = var.vpc1_subnet_cidr
  availability_zone = var.availability_zone
  instance_type     = var.instance_type
  peer_cidrs        = [var.vpc2_cidr, var.vpc3_cidr]
}

module "vpc2" {
  source = "./modules/vpc"

  name              = "vpc-2"
  vpc_cidr          = var.vpc2_cidr
  subnet_cidr       = var.vpc2_subnet_cidr
  availability_zone = var.availability_zone
  instance_type     = var.instance_type
  peer_cidrs        = [var.vpc1_cidr, var.vpc3_cidr]
}

module "vpc3" {
  source = "./modules/vpc"

  name              = "vpc-3"
  vpc_cidr          = var.vpc3_cidr
  subnet_cidr       = var.vpc3_subnet_cidr
  availability_zone = var.availability_zone
  instance_type     = var.instance_type
  peer_cidrs        = [var.vpc1_cidr, var.vpc2_cidr]
}

module "transit_gateway" {
  source = "./modules/transit-gateway"

  name = "tgw-three-vpcs"

  vpcs = {
    vpc1 = {
      vpc_id    = module.vpc1.vpc_id
      subnet_id = module.vpc1.subnet_id
      cidr      = var.vpc1_cidr
    }
    vpc2 = {
      vpc_id    = module.vpc2.vpc_id
      subnet_id = module.vpc2.subnet_id
      cidr      = var.vpc2_cidr
    }
    vpc3 = {
      vpc_id    = module.vpc3.vpc_id
      subnet_id = module.vpc3.subnet_id
      cidr      = var.vpc3_cidr
    }
  }
}

# Each VPC needs routes to the two remote VPC CIDRs through the TGW.
# These routes are kept in the root module to avoid a circular dependency:
# the TGW module needs VPC IDs/subnet IDs, while VPC routes need the TGW ID.
locals {
  vpc_route_entries = flatten([
    for vpc_key, vpc in {
      vpc1 = {
        route_table_id = module.vpc1.route_table_id
        peer_cidrs     = [var.vpc2_cidr, var.vpc3_cidr]
      }
      vpc2 = {
        route_table_id = module.vpc2.route_table_id
        peer_cidrs     = [var.vpc1_cidr, var.vpc3_cidr]
      }
      vpc3 = {
        route_table_id = module.vpc3.route_table_id
        peer_cidrs     = [var.vpc1_cidr, var.vpc2_cidr]
      }
    } : [
      for cidr in vpc.peer_cidrs : {
        key                = "${vpc_key}-${replace(cidr, "/", "-")}"
        route_table_id     = vpc.route_table_id
        destination_cidr   = cidr
      }
    ]
  ])
}

resource "aws_route" "to_remote_vpcs" {
  for_each = {
    for route in local.vpc_route_entries : route.key => route
  }

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr
  transit_gateway_id     = module.transit_gateway.transit_gateway_id
}
