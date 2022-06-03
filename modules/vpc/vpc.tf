resource "aws_vpc" "lab1" {
  enable_dns_support   = var.enable_dns_hostnames
  enable_dns_hostnames = var.enable_dns_hostnames
  cidr_block           = var.vpc_cidr

  tags = var.tags
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az_num = length(data.aws_availability_zones.available.names)
}

resource "aws_subnet" "private" {
  count             = local.az_num
  vpc_id            = aws_vpc.lab1.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr,3,count.index)
  
  tags = merge(
    var.tags,
    {
      Name = "private"
    }
  )
}

resource "aws_subnet" "public" {
  count             = local.az_num
  vpc_id            = aws_vpc.lab1.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr,3,count.index+local.az_num)
  
  tags = merge(
    var.tags,
    {
      Name = "public"
    }
  )
}


resource "aws_network_acl" "private_acl" {
  vpc_id       = aws_vpc.lab1.id 

  ingress  {
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    protocol   = "all"
    from_port  = 0
    to_port    = 0
  }
  egress {
    protocol   = "all"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
  }
  
  tags = merge(
    var.tags,
    {
      Name = "private_acl"
    }
  )
}

# data "aws_subnet" "created_private" {
#   #id = aws_subnet.private.id
#   filter {
#     name   = "tag:Name"
#     values = ["private"]
#   }
# }

# # data "aws_subnet" "created_public" {
# #   filter {
# #     name   = "tag:Name"
# #     values = ["public"]
# #   }
# # }

# resource "aws_network_acl_association" "name" {
#   count          = data.aws_subnet.created_private
#   network_acl_id = aws_network_acl.private_acl.id
#   subnet_id      = aws_subnet.private.*.id[count.index]
  
# }

resource "aws_security_group" "aws_sg" {
  name   = "sg_lab1"
  tags   = var.tags
  vpc_id = aws_vpc.lab1.id

    egress { 
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aws_sg.id
}

resource "aws_security_group_rule" "http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aws_sg.id
}

resource "aws_security_group_rule" "https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aws_sg.id
}