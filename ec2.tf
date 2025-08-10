data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["vpc-main"]
  }
}

module "ec2_instance_application_1" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = var.application_instance_name

  ami = var.ami

  instance_type = var.instance_size
  key_name      = var.key_name
  monitoring    = true

  create_security_group = true
  security_group_vpc_id = data.aws_vpc.selected.id

  user_data = file("apache_install.sh")

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "ec2_instance_application_2" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = var.application_instance_name

  ami = var.ami

  instance_type = var.instance_size
  key_name      = var.key_name
  monitoring    = true

  create_security_group = true
  security_group_vpc_id = data.aws_vpc.selected.id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "ec2_instance_management_1" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = var.management_instance_name

  ami = var.ami

  instance_type = var.instance_size
  key_name      = var.key_name
  monitoring    = true

  create_security_group = true
  security_group_vpc_id = data.aws_vpc.selected.id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "ec2_instance_management_2" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = var.management_instance_name

  ami = var.ami

  instance_type = var.instance_size
  key_name      = var.key_name
  monitoring    = true

  create_security_group = true
  security_group_vpc_id = data.aws_vpc.selected.id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
