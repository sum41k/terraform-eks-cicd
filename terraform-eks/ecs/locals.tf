# locals {
#   // Port range from https://aws.amazon.com/premiumsupport/knowledge-center/troubleshoot-unhealthy-checks-ecs
#   tasks_port_range = {
#     from = 32768
#     to   = 65535
#   }
# }

locals {
  min_eph_port = 32768
  max_eph_port = 65535
}
