output "cluster_id" {
  description = "The ID of the cluster"
  value       = "${aws_ecs_cluster.ecs-cluster.id}"
}

output "cluster_arn" {
  description = "The ARN of the cluster"
  value       = "${aws_ecs_cluster.ecs-cluster.arn}"
}

output "cluster_join_command" {
  description = "The join command to join the cluster, to run on the EC2 Host Instance."

  value = <<EOF
echo ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config
echo ECS_DATADIR=/data >> /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE=true >> /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true >> /etc/ecs/ecs.config
echo ECS_LOGFILE=/log/ecs-agent.log >> /etc/ecs/ecs.config
echo ECS_AVAILABLE_LOGGING_DRIVERS='["json-file","awslogs"]' >> /etc/ecs/ecs.config
echo ECS_LOGLEVEL=info >> /etc/ecs/ecs.config
EOF
}
