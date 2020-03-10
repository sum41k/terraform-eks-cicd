# resource "aws_route53_zone" "public" {
#   count = var.create_external_zone ? 1 : 0
#   name  = var.platform_external_subdomain
# }
#
# data "aws_route53_zone" "public" {
#   count        = ! var.create_external_zone && var.platform_external_subdomain != "" ? 1 : 0
#   name         = var.platform_external_subdomain
#   private_zone = false
# }
#
# resource "aws_route53_record" "public_wildcard" {
#   count   = var.platform_external_subdomain != "" ? 1 : 0
#   zone_id = coalesce(join("", data.aws_route53_zone.public.*.zone_id), join("", aws_route53_zone.public.*.zone_id))
#   name    = "*.${var.platform_name}.${var.platform_external_subdomain}"
#   type    = "CNAME"
#   ttl     = "300"
#
#   records = [
#     module.alb.this_lb_dns_name,
#   ]
# }
