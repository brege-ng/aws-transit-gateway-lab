variable "name" {
  description = "Name prefix used for resources in this VPC."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of this VPC."
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block of the subnet hosting the EC2 and TGW attachment."
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone for the subnet."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "peer_cidrs" {
  description = "CIDR blocks of remote VPCs allowed to send ICMP traffic to this VPC."
  type        = list(string)
  default     = []
}
