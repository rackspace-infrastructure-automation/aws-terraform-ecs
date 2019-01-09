provider "aws" {
  version    = "~> 1.2"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.0.6"

  vpc_name = "ECS-FARGATE-Example-VPC"
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow inbound web traffic"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "ecs_cluster" {
  source           = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ecs//modules/cluster/?ref=v0.0.2"
  ecs_cluster_name = "${var.ecs_cluster_name}"
}

resource "aws_iam_role" "ecs_role_task_assume" {
  name = "ecsfargate_task_assume"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_task_assume_policy" {
  name = "ecsfargate_task_assume_policy"
  role = "${aws_iam_role.ecs_role_task_assume.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

data "aws_region" "current_region" {}
data "aws_caller_identity" "current" {}

data "template_file" "fargate-sample-app" {
  template = "${file("fargate-sample-app.json")}"

  vars {
    AWS_REGION = "${var.aws_region}"
    LOGS_GROUP = "${aws_cloudwatch_log_group.fargate-sample-app.name}"
  }
}

resource "aws_cloudwatch_log_group" "fargate-sample-app" {
  name              = "/ecs/fargate-sample-app"
  retention_in_days = 30

  tags {
    Name = "fargate-sample-app"
  }
}

resource "aws_ecs_task_definition" "ecs_task_def" {
  family                   = "${lower(var.task_name)}"
  container_definitions    = "${data.template_file.fargate-sample-app.rendered}"
  execution_role_arn       = "${aws_iam_role.ecs_role_task_assume.arn}"
  network_mode             = "${var.network_mode}"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.task_cpu}"
  memory                   = "${var.task_memory}"
}

resource "aws_ecs_service" "ecs_service_def" {
  name            = "${lower(var.service_name)}"
  cluster         = "${module.ecs_cluster.cluster_id}"
  task_definition = "${aws_ecs_task_definition.ecs_task_def.arn}"
  desired_count   = "${var.ecs_service_desired_count}"
  launch_type     = "FARGATE"

  network_configuration = {
    subnets          = ["${element(module.vpc.public_subnets, 0)}", "${element(module.vpc.public_subnets, 1)}"]
    security_groups  = ["${aws_security_group.allow_web.id}"]
    assign_public_ip = "true"
  }
}
