variable "vpc_cidr" {
  description = "Cidr range for VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "private_subnets" {
  description = "Range of private subnets"
  type        = list(string)
  default     = ["10.1.11.0/24", "10.1.12.0/24"]
}

variable "intra_subnets" {
  description = "Range of intra subnets"
  type        = list(string)
  default     = ["10.1.13.0/24", "10.1.14.0/24"]
}

variable "public_subnets" {
  description = "Range of public subnets"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "vpc_sg_name" {
  description = "Name of the SG in VPC"
  type        = string
  default     = "vpc_sg"
}

variable "management_instance_name" {
  description = "Name of Management instances"
  type        = string
  default     = "management"
}

variable "instance_size" {
  description = "Size of instances"
  type        = string
  default     = "t2.micro"
}

variable "application_asg_name" {
  description = "Name of Application ASG"
  type        = string
  default     = "application-asg"
}

variable "launch_template_description" {
  description = "Description of launch template"
  type        = string
  default     = "Launch template application"
}