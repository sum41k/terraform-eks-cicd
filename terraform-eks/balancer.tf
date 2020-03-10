module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name = "my-alb"

  load_balancer_type = "application"

  vpc_id          = "${data.aws_vpc.default.id}"
  subnets         = "${data.aws_subnet_ids.default.ids}"
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

#ALB SG
resource "aws_security_group" "alb_sg" {
  name        = "${var.name}-alb_sg"
  description = "SG for ALB purposes"
  vpc_id      = "${data.aws_vpc.default.id}"
}

resource "aws_security_group_rule" "allow_http_ingress" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  security_group_id = "${aws_security_group.alb_sg.id}"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_egress" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  security_group_id = "${aws_security_group.alb_sg.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}
