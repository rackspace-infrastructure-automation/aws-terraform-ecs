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
  default     = "ECS_EC2_Cluster_Example"
}

variable "ec2_keypair" {
  description = "SSH keypair in the region to be built for the EC2 Instances"
  default     = "my_ec2_keypair"
}

variable "task_name" {
  default = "ec2ecs_test_task"
}

variable "service_name" {
  default = "ec2ecs_test_service"
}

variable "network_mode" {
  default = "bridge"
}

variable "ecs_service_desired_count" {
  default = "1"
}
