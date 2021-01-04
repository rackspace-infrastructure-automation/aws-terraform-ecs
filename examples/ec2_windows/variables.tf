variable "aws_region" {
  description = "AWS REGION"
  type        = string
  default     = "us-east-2"
}

variable "ecs_cluster_name" {
  description = "The environment we are building for"
  default     = "ECS_Windows_Cluster_Example"
  type        = string
}

variable "ec2_keypair" {
  description = "SSH keypair for the EC2 Instances available in the build region"
  default     = "my_ec2_keypair"
  type        = string
}

variable "service_name" {
  description = "The name of the service"
  type        = string
  default     = "win_ec2_ecs_test_service"
}

variable "task_name" {
  description = "The name for the task"
  type        = string
  default     = "mycooltaskname"
}
