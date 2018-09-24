resource "aws_ecs_task_definition" "ecs_task_def" {
  family                = "${lower(var.task_name)}"
  container_definitions = "${var.container_definition}"
  execution_role_arn    = "${format("arn:aws:iam::%s:role/ecsTaskExecutionRole", data.aws_caller_identity.current.account_id)}"
  network_mode          = "${var.network_mode}"
}

resource "aws_ecs_service" "ecs_service_def" {
  name            = "${lower(var.service_name)}"
  cluster         = "${aws_ecs_cluster.cluster.id}"
  task_definition = "${aws_ecs_task_definition.ecs_task_def.arn}"
  desired_count   = "${var.ecs_service_desired_count}"
}
