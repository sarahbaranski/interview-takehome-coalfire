data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0"

  name = "vpc-coalfire"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  intra_subnets = var.intra_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  manage_default_route_table = true

  manage_default_security_group  = true
  default_security_group_name    = var.vpc_sg_name
  default_security_group_ingress = []
  default_security_group_egress  = []

  private_subnet_tags = { Type = "private"}
  intra_subnet_tags = { Type = "intra" }

  map_public_ip_on_launch = true

  tags = {
    Name        = "coalfire-vpc"
    Environment = "Development"
  }
}
