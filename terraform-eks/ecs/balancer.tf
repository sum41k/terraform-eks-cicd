# #Target group
# # Application Load balancer
# resource "aws_lb" "web_alb" {
#   name               = "test-web-alb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = ["${aws_security_group.alb_sg.id}"]
#   subnets            = var.public_subnets_id
#   # ["${aws_subnet.public.*.id}"]
# }
#
# # Creating ALB target group
# resource "aws_lb_target_group" "test_tg" {
#
#   name       = "test-tg"
#   port       = "80"
#   protocol   = "HTTP"
#   vpc_id     = var.vpc_id
#   depends_on = ["aws_lb.web_alb"]
# }
#
# # Creating ALB http listener
# resource "aws_lb_listener" "web_listener" {
#   load_balancer_arn = "${aws_lb.web_alb.arn}"
#   port              = "80"
#   protocol          = "HTTP"
#   default_action {
#     target_group_arn = "${aws_lb_target_group.test_tg.arn}"
#     type             = "forward"
#   }
# }

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name = "my-alb"

  load_balancer_type = "application"

  vpc_id          = var.vpc_id
  subnets         = var.public_subnets_id
  security_groups = ["${aws_security_group.alb_sg.id}"]

  target_groups = [
    {
      name_prefix      = "test"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "Test"
  }
}
