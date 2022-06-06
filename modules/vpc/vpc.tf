resource "aws_vpc" "lab1" {
  enable_dns_support   = var.enable_dns_hostnames
  enable_dns_hostnames = var.enable_dns_hostnames
  cidr_block           = var.vpc_cidr

  tags = var.tags
}

data "aws_availability_zones" "available" {
  state = "available"
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
  subnet_ids   = aws_subnet.private.*.id
 
  ingress  {
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    protocol   = "all"
    from_port  = 0
    to_port    = 0
  }
  egress {
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    protocol   = "all"
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
  #cidr_blocks      = ["0.0.0.0/0"]
  cidr_blocks       = aws_subnet.public.*.cidr_block
  security_group_id = aws_security_group.aws_sg.id
}

resource "aws_security_group_rule" "http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  #cidr_blocks      = ["0.0.0.0/0"]
  cidr_blocks       = aws_subnet.public.*.cidr_block
  security_group_id = aws_security_group.aws_sg.id
}

resource "aws_security_group_rule" "https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  #cidr_blocks      = ["0.0.0.0/0"]
  cidr_blocks       = aws_subnet.public.*.cidr_block
  security_group_id = aws_security_group.aws_sg.id
}

resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.lab1.id

  tags = merge(
    var.tags,
    {
      Name = "private_routing"
    }
  )
}

resource "aws_route_table_association" "rt_associate_private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.rt_private.id
}