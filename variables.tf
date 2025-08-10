variable "vpc_cidr" {
  type = string
  default = "10.1.0.0/16"
}

variable "private_subnet_ids" {
  type = list(string)
  default = ["10.1.11.0/24", "10.1.12.0/24", "10.1.13.0/24", "10.1.14.0/24"]
}

variable "public_subnet_ids" {
  type = list(string)
  default = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "vpc_sg_name" {
  type = string
  default = "vpc_sg"
}
