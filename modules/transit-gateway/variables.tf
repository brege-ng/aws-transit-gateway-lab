variable "name" {
  description = "Name tag for the Transit Gateway."
  type        = string
}

variable "vpcs" {
  description = "VPC details used to create TGW attachments and static routes."
  type = map(object({
    vpc_id    = string
    subnet_id = string
    cidr      = string
  }))
}
