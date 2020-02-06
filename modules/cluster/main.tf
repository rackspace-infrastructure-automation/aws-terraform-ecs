/**
*# aws-terraform-ecs/modules/cluster
*
*This submodule creates an ecs cluster
*
*## Basic Usage
*
*```
*module "ecs" {
*  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ecs//modules/cluster/?ref=v0.0.3"
*
*  cluster_name = "MyCluster"
*
*  tags = {
*    Terraform = "true"
*  }
*}
*```
*
* Full working references are available at [examples](examples)
*/

terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = ">= 2.1.0"
  }
}

locals {
  tags = {
    Environment     = var.environment
    ServiceProvider = "Rackspace"
  }
}

resource "aws_ecs_cluster" "ecs-cluster" {
  name = var.name

  tags = merge(local.tags, var.tags)
}

