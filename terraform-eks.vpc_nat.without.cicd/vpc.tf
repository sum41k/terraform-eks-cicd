# module "vpc" {
#   source             = "terraform-aws-modules/vpc/aws"
#   name               = "main-${var.candidate}"
#   cidr               = "10.0.0.0/16"
#   azs                = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
#   private_subnets    = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
#   public_subnets     = ["10.0.200.0/24", "10.0.201.0/24", "10.0.202.0/24"]
#   enable_nat_gateway = true
#   single_nat_gateway = true
#
#   tags = {
#     Managed     = "terraform"
#     Environment = "${var.environment}"
#   }
# }
