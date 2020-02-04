variable "aws_access_key" {
  description = "AWS Access Key stored in secrets"
  type        = string
}

variable "aws_region" {
  description = "AWS REGION"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS Secret Key stored in secrets"
  type        = string
}

variable "ec2_keypair" {
  description = "SSH keypair for the EC2 Instances available in the build region"
  type        = string
}

variable "ecs_cluster_name" {
  description = "The name to be given to the ECS cluster"
  type        = string
}

variable "ecs_service_desired_count" {
  description = "Desired count for the ECS service"
  type        = string
}

variable "environment" {
  description = "The environment we are building for"
  type        = string
}

variable "service_name" {
  description = "The name of the service"
  type        = string
}

variable "task_name" {
  description = "The name for the task"
  type        = string
}

