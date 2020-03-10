# module "ecs" {
#   source = "./ecs"
#
#   name               = "${var.candidate}-candidate-test"
#   vpc_id             = "${module.vpc.vpc_id}"
#   private_subnets_id = "${module.vpc.private_subnets}"
#   public_subnets_id  = "${module.vpc.public_subnets}"
#   nat_public_ips     = "${module.vpc.nat_public_ips}"
# }
