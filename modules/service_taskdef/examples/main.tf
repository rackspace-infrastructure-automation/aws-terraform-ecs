terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region  = "us-west-2"
  version = "~> 2.7"
}

resource "aws_ecs_task_definition" "ecs_task_def" {
  container_definitions = var.container_definition
  execution_role_arn = format(
    "arn:aws:iam::%s:role/ecsTaskExecutionRole",
    data.aws_caller_identity.current.account_id,
  )
  family       = lower(var.task_name)
  network_mode = var.network_mode
}

resource "aws_ecs_service" "ecs_service_def" {
  name            = lower(var.service_name)
  cluster         = aws_ecs_cluster.cluster.id
  desired_count   = var.ecs_service_desired_count
  task_definition = aws_ecs_task_definition.ecs_task_def.arn
}

