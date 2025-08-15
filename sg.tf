module "asg_sg" {
  source  = "terraform-aws-modules/security-group/aws"

  name        = "asg-instance-sg"
  description = "Security group for ASG instances"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = ["http-80-tcp", "https-443-tcp", "ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules  = ["all-all"]
}
