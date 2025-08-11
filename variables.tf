variable "vpc_cidr" {
  description = "Cidr range for VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "private_subnet_ids" {
  description = "Range of private subnet ids"
  type        = list(string)
  default     = ["10.1.11.0/24", "10.1.12.0/24", "10.1.13.0/24", "10.1.14.0/24"]
}

variable "public_subnet_ids" {
  description = "Range of public subnet ids"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "vpc_sg_name" {
  description = "Name of the SG in VPC"
  type        = string
  default     = "vpc_sg"
}

variable "application_instance_name" {
  description = "Name of Application instances"
  type        = string
  default     = "application"
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

variable "ami" {
  description = "AMI id"
  type        = string
  default     = "ami-0de716d6197524dd9"
}

# This needs to be set up as the default value is an empty string
variable "key_name" {
  description = "Name of EC2 key pair"
  type        = string
  default     = ""
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