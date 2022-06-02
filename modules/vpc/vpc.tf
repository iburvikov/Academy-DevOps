resource "aws_vpc" "lab1" {
  enable_dns_support = var.enable_dns_hostnames
  enable_dns_hostnames = var.enable_dns_hostnames
  cidr_block = var.vpc_cidr

  tags = var.tags
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az_num = length(data.aws_availability_zones.available.names)
}

resource "aws_subnet" "private" {
  count = local.az_num
  vpc_id = aws_vpc.lab1.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block = cidrsubnet(var.vpc_cidr,3,count.index)
  
  tags = merge(
    var.tags,
    {
      Name = "private-${count.index}"
    }
  )
}

resource "aws_subnet" "public" {
  count = local.az_num
  vpc_id = aws_vpc.lab1.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block = cidrsubnet(var.vpc_cidr,3,count.index+local.az_num)
  
  tags = merge(
    var.tags,
    {
      Name = "public-${count.index}"
    }
  )
}

resource "aws_network_acl" "private_acl" {
  vpc_id = aws_vpc.lab1.id 

  tags = var.tags
  
}

# resource "aws_network_acl_association" "private_acl_association" {
#      network_acl_id = aws_network_acl.private_acl.id
#      subnet_id = aws_subnet.private.id
# }