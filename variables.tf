variable "aws_region" {
  description = "AWS region in which all resources will be created."
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone used by the three VPC subnets and TGW attachments."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type used in each VPC."
  type        = string
  default     = "t3.micro"
}

variable "vpc1_cidr" {
  description = "CIDR block of VPC 1."
  type        = string
}

variable "vpc2_cidr" {
  description = "CIDR block of VPC 2."
  type        = string
}

variable "vpc3_cidr" {
  description = "CIDR block of VPC 3."
  type        = string
}

variable "vpc1_subnet_cidr" {
  description = "Subnet CIDR used inside VPC 1."
  type        = string
}

variable "vpc2_subnet_cidr" {
  description = "Subnet CIDR used inside VPC 2."
  type        = string
}

variable "vpc3_subnet_cidr" {
  description = "Subnet CIDR used inside VPC 3."
  type        = string
}
