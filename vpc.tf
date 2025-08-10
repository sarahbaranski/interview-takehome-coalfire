data "aws_availability_zones" "available" {
    state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0"

  name = "vpc-main"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets  = var.public_subnet_ids
  private_subnets = var.private_subnet_ids

  enable_nat_gateway = true
  single_nat_gateway = true

  manage_default_route_table = true

  manage_default_security_group  = true
  default_security_group_name    = var.vpc_sg_name
  default_security_group_ingress = []
  default_security_group_egress  = []

  tags = {
    Name = "vpc-main"
    Environment = "dev"
  }
}
