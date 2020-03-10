# data "aws_vpc" "selected" {
#   id = "${var.vpc_id}"
# }

data "template_file" "assume_role" {
  template = "${file("${path.module}/files/role.json")}"
}

resource "aws_iam_role" "ecs_host" {
  name               = "${var.name}-ecs-host"
  assume_role_policy = "${data.template_file.assume_role.rendered}"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role       = "${aws_iam_role.ecs_host.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  role       = "${aws_iam_role.ecs_host.id}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

#ECS SG
resource "aws_security_group" "ecs_cluster_sg" {
  name        = "${var.name}-role-ecs-host"
  description = "ECS default security group"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "allow_ephemeral_ingress" {
  type      = "ingress"
  from_port = "${local.min_eph_port}"
  to_port   = "${local.max_eph_port}"
  protocol  = "tcp"

  security_group_id        = "${aws_security_group.ecs_cluster_sg.id}"
  source_security_group_id = "${aws_security_group.alb_sg.id}"
}

resource "aws_security_group_rule" "allow_ecs_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.ecs_cluster_sg.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

#ALB SG
resource "aws_security_group" "alb_sg" {
  name        = "${var.name}-alb_sg"
  description = "SG for ALB purposes"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "allow_http_ingress" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  security_group_id = "${aws_security_group.alb_sg.id}"

  #cidr_blocks = "${var.allowed_cidrs}"
  cidr_blocks = ["0.0.0.0/0"]
  #source_security_group_id = "${var.bastion_asg_sg}"
}

resource "aws_security_group_rule" "allow_ephemeral_egress" {
  type      = "egress"
  from_port = "${local.min_eph_port}"
  to_port   = "${local.max_eph_port}"
  protocol  = "tcp"

  security_group_id = "${aws_security_group.alb_sg.id}"
  #source_security_group_id = "${aws_security_group.ecs_cluster_sg.id}"
  cidr_blocks = ["0.0.0.0/0"]
}

#Security Group for Web ASG
resource "aws_security_group" "test_web-asg" {
  name        = "${var.name}-web-asg"
  description = "SG for ASG purposes"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "asg_http_eph" {
  type      = "ingress"
  from_port = "${local.min_eph_port}"
  to_port   = "${local.max_eph_port}"
  protocol  = "tcp"

  security_group_id        = "${aws_security_group.test_web-asg.id}"
  source_security_group_id = "${aws_security_group.alb_sg.id}"
}

resource "aws_security_group_rule" "asg_egress" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  security_group_id = "${aws_security_group.test_web-asg.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "default_sg_nat_ingress" {
  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  security_group_id = "${aws_security_group.test_web-asg.id}"
  cidr_blocks       = formatlist("%s/32", var.nat_public_ips)
  description       = "NAT Gateway"
}

resource "aws_security_group_rule" "allow_ssh" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  security_group_id = "${aws_security_group.test_web-asg.id}"
  #source_security_group_id = "${aws_security_group.bastion_instance.id}"
  cidr_blocks = ["0.0.0.0/0"]
  #var.bastion_asg_sg
}
# resource "aws_security_group" "role_ecs_host" {
#   name        = "${var.name}-role-ecs-host"
#   description = "ECS default security group"
#   vpc_id      = "${var.vpc_id}"
#
#   // Allow traffic from VPC to ECS tasks
#   ingress {
#     from_port   = "${local.tasks_port_range["from"]}"
#     to_port     = "${local.tasks_port_range["to"]}"
#     protocol    = "TCP"
#     cidr_blocks = ["${data.aws_vpc.selected.cidr_block}"]
#   }
#
#   egress {
#     from_port = 0
#     to_port   = 0
#     protocol  = "-1"
#
#     cidr_blocks = [
#       "0.0.0.0/0",
#     ]
#   }
# }

// Normally when you create the a schedule task from the interface
// AWS automatically creates a role called ecsEventsRole that can
// run the task, so this replicates that functionality
// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/CWE_IAM_role.html
# resource "aws_iam_role" "event_role" {
#   name = "${var.name}-ecsEventsRole"
#
#   assume_role_policy = <<EOF
# {
#   "Version": "2008-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": [
#           "events.amazonaws.com"
#         ]
#       },
#       "Effect": "Allow"
#     }
#   ]
# }
# EOF
# }
#
# resource "aws_iam_role_policy_attachment" "event_policy" {
#   role       = "${aws_iam_role.event_role.id}"
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
# }
