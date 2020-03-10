variable "name" {
  default = "candidate-test"
}

variable "vpc_id" {
  default = ""
}

variable "instance_type" {
  default = "t2.micro"
}

variable "private_subnets_id" {}

variable "public_subnets_id" {}

variable "nat_public_ips" {}

variable "app_port" {
  default = "80"
}
