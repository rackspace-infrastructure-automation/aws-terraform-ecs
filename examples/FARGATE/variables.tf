variable "aws_region" {
  description = "AWS REGION"
  default     = "us-east-2"
  type        = string
}

variable "aws_access_key" {
  description = "AWS Access Key stored in secrets"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS Secret Key stored in secrets"
  type        = string
}

variable "environment" {
  description = "The environment we are building for"
  default     = "Test"
  type        = string
}

variable "ecs_cluster_name" {
  description = "The environment we are building for"
  default     = "ECS_FARGATE_Cluster_Example"
  type        = string
}

variable "task_name" {
  description = "The name of the ECS task."
  default     = "ecs_fargate_test_task"
  type        = string
}

variable "service_name" {
  description = "The name of the ECS service."
  default     = "ecs_fargate_test_service"
  type        = string
}

variable "network_mode" {
  description = "What network mode we are running in."
  default     = "awsvpc"
  type        = string
}

variable "ecs_service_desired_count" {
  description = "The desired count of the ECS service."
  default     = "1"
  type        = string
}

variable "task_cpu" {
  description = "The tasks desired CPU."
  default     = "256"
  type        = string
}

variable "task_memory" {
  description = "The tasks desired memory."
  default     = "512"
  type        = string
}

