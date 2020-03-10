output "password" {
  value = "${aws_iam_user_login_profile.candidate.encrypted_password}"
}

# output "public_subnets_id" {
#   description = "Public subnets ids"
#   value       = module.vpc.public_subnets
# }
#
# output "private_subnets_id" {
#   description = "Private subnets ids"
#   value       = module.vpc.private_subnets
# }
#
# output "vpc_id" {
#   description = "VPC id"
#   value       = module.vpc.vpc_id
# }
#
# output "nat_public_ips" {
#   value = module.vpc.nat_public_ips
# }

output "alb_dns_name" {
  value = module.alb.this_lb_dns_name
}
