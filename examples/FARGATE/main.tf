terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region  = var.aws_region
  version = "~> 2.1"
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.12.0"

  name = "ECS-FARGATE-Example-VPC"
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow inbound web traffic"
  vpc_id      = module.vpc.vpc_id

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
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ecs//modules/cluster/?ref=v0.12.0"

  name = var.ecs_cluster_name
}

data "aws_iam_policy_document" "ecs_role_task_assume" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_role_task_assume" {
  name               = "ecsfargate_task_assume"
  assume_role_policy = data.aws_iam_policy_document.ecs_role_task_assume.json
}

data "aws_iam_policy_document" "ecs_task_assume_policy" {

  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecs_task_assume_policy" {
  name = "ecsfargate_task_assume_policy"
  role = aws_iam_role.ecs_role_task_assume.id

  policy = data.aws_iam_policy_document.ecs_task_assume_policy.json

}

data "aws_region" "current_region" {
}

data "aws_caller_identity" "current" {
}

data "template_file" "fargate-sample-app" {
  template = file("fargate-sample-app.json")

  vars = {
    AWS_REGION = var.aws_region
    LOGS_GROUP = aws_cloudwatch_log_group.fargate-sample-app.name
  }
}

resource "aws_cloudwatch_log_group" "fargate-sample-app" {
  name              = "/ecs/fargate-sample-app"
  retention_in_days = 30

  tags = {
    Name = "fargate-sample-app"
  }
}

resource "aws_ecs_task_definition" "ecs_task_def" {
  container_definitions    = data.template_file.fargate-sample-app.rendered
  cpu                      = var.task_cpu
  execution_role_arn       = aws_iam_role.ecs_role_task_assume.arn
  family                   = lower(var.task_name)
  memory                   = var.task_memory
  network_mode             = var.network_mode
  requires_compatibilities = ["FARGATE"]
}

resource "aws_ecs_service" "ecs_service_def" {
  cluster         = module.ecs_cluster.cluster_id
  desired_count   = var.ecs_service_desired_count
  launch_type     = "FARGATE"
  name            = lower(var.service_name)
  task_definition = aws_ecs_task_definition.ecs_task_def.arn

  network_configuration {
    assign_public_ip = "true"
    security_groups  = [aws_security_group.allow_web.id]
    subnets          = [element(module.vpc.public_subnets, 0), element(module.vpc.public_subnets, 1)]
  }
}
