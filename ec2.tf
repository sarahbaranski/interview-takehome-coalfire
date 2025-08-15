data "aws_caller_identity" "current" {}

resource "aws_kms_key" "ebs_key" {
  description         = "ebs key for ec2-module"
  policy              = data.aws_iam_policy_document.ebs_key.json
  enable_key_rotation = true
}

data "aws_iam_policy_document" "ebs_key" {
  statement {
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
  }
}

# Datasource to call AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical owner ID for Ubuntu AMIs

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 instance for management tier
module "ec2_instance_managment" {
  source = "github.com/Coalfire-CF/terraform-aws-ec2"

  name = var.management_instance_name

  ami               = data.aws_ami.ubuntu.image_id
  ec2_instance_type = var.instance_size
  instance_count    = 2

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  ec2_key_pair    = "ec2-module-test"
  ebs_optimized   = false
  ebs_kms_key_arn = aws_kms_key.ebs_key.arn

  # Storage
  root_volume_size = "20"

  #  Security Group Rules
  egress_rules = {
    "allow_all_egress" = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all egress"
    }
  }

  # Tagging
  global_tags = {}
}
