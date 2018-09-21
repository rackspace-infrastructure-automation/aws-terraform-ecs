variable "aws_region" {
  description = "AWS REGION"
  default     = "us-east-2"
}

variable "aws_access_key" {
  description = "AWS Access Key stored in secrets"
}

variable "aws_secret_key" {
  description = "AWS Secret Key stored in secrets"
}

variable "environment" {
  description = "The environment we are building for"
  default     = "Test"
}

variable "ecs_cluster_name" {
  description = "The environment we are building for"
  default     = "ECS_FARGATE_Cluster_Example"
}

variable "task_name" {
  default = "ecs_fargate_test_task"
}

variable "service_name" {
  default = "ecs_fargate_test_service"
}

variable "network_mode" {
  default = "awsvpc"
}

variable "ecs_service_desired_count" {
  default = "1"
}

variable "task_cpu" {
  default = "256"
}

variable "task_memory" {
  default = "512"
}
