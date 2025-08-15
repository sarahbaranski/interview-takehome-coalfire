module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "8.0.1"

  # Autoscaling group
  name = var.application_asg_name

  min_size                  = 2
  max_size                  = 6
  desired_capacity          = 2
  wait_for_capacity_timeout = 0
  health_check_type         = "ELB" # allows the ALB to control how the health checking is done
  vpc_zone_identifier       = module.vpc.private_subnets
  user_data                 = file("apache_install.sh")

  initial_lifecycle_hooks = [
    {
      name                 = "ApplicationStartupLifeCycleHook"
      default_result       = "CONTINUE"
      heartbeat_timeout    = 60
      lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
      # notification_metadata = jsonencode({ "hello" = "world" })
    },
    {
      name                 = "ApplicationTerminationLifeCycleHook"
      default_result       = "CONTINUE"
      heartbeat_timeout    = 180
      lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"
      # notification_metadata = jsonencode({ "goodbye" = "world" })
    }
  ]
  security_groups = [module.asg_sg.security_group_id]

  # Launch template
  launch_template_name        = var.application_asg_name
  launch_template_description = var.launch_template_description
  update_default_version      = true

  image_id          = data.aws_ami.ubuntu.image_id
  instance_type     = var.instance_size
  ebs_optimized     = false
  enable_monitoring = true

  # This will ensure imdsv2 is enabled, required, and a single hop which is aws security
  # best practices
  # See https://docs.aws.amazon.com/securityhub/latest/userguide/autoscaling-controls.html#autoscaling-4
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Environment = "dev"
    Project     = "coalfire"
  }
}
