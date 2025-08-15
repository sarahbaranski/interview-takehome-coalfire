module "asg_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "coalfire-asg-sg"
  description = "Security group for ASG instances"
  vpc_id      = module.vpc.vpc_id

  ingress_rules       = ["http-80-tcp", "https-443-tcp", "ssh-tcp"]
  ingress_cidr_blocks = ["10.1.0.0/16"]
  egress_rules        = ["all-all"]
}
