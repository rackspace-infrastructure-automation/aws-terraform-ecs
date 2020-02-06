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
  default     = "ECS_EC2_Cluster_Example"
  type        = string
}

variable "ec2_keypair" {
  description = "SSH keypair in the region to be built for the EC2 Instances"
  default     = "my_ec2_keypair"
  type        = string
}

variable "task_name" {
  description = "The name of the task you are creating."
  default     = "ec2ecs_test_task"
  type        = string
}

variable "service_name" {
  description = "The name of the service you are creating."
  default     = "ec2ecs_test_service"
  type        = string
}

variable "network_mode" {
  description = "The network mode you are using."
  default     = "bridge"
  type        = string
}

variable "ecs_service_desired_count" {
  description = "The desired count of services running."
  default     = "1"
  type        = string
}

