output "cluster_arn" {
  description = "The ARN of the cluster"
  value       = aws_ecs_cluster.ecs-cluster.arn
}

output "cluster_id" {
  description = "The ID of the cluster"
  value       = aws_ecs_cluster.ecs-cluster.id
}

output "cluster_join_command_linux" {
  description = "The command to join the cluster, to run on a Linux EC2 Instance."

  value = <<EOF
echo ECS_CLUSTER=${var.cluster_name} >> /etc/ecs/ecs.config
echo ECS_DATADIR=/data >> /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE=true >> /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true >> /etc/ecs/ecs.config
echo ECS_LOGFILE=/log/ecs-agent.log >> /etc/ecs/ecs.config
echo ECS_AVAILABLE_LOGGING_DRIVERS='["json-file","awslogs"]' >> /etc/ecs/ecs.config
echo ECS_LOGLEVEL=info >> /etc/ecs/ecs.config
EOF

}

output "cluster_join_command_windows" {
  description = "The command to join the cluster, to run on a Windows EC2 Instance."

  value = <<EOF
Import-Module ECSTools
Initialize-ECSAgent -Cluster '${var.cluster_name}' -EnableTaskIAMRole
EOF

}

