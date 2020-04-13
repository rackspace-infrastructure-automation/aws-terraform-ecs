/**
* # aws-terraform-ecs/modules/cluster
*
* This submodule creates an ecs cluster
*
* ## Basic Usage
*
* ```
* module "ecs" {
*   source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ecs//modules/cluster/?ref=v0.12.0"
*
*   name = "MyCluster"
*
*   tags = {
*     Terraform = "true"
*   }
* }
* ```
*
* Full working references are available at [examples](examples)
*
* ## Terraform 0.12 upgrade
*
* Several changes were required while adding terraform 0.12 compatibility.  The following changes should be
* made when upgrading from a previous release to version 0.12.0 or higher.
*
* ### Terraform State File
*
* Several resources were updated with new logical names, better meet current Rackspace style guides.
* The following statements can be used to update existing resources.  In each command, `<MODULE_NAME>`
* should be replaced with the logic name used where the module is referenced.
*
* ```
* terraform state mv module.<MODULE_NAME>.aws_ecs_cluster.ecs-cluster module.<MODULE_NAME>.aws_ecs_cluster.ecs_cluster
* ```
*/

terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = ">= 2.7.0"
  }
}

locals {
  tags = {
    Environment     = var.environment
    ServiceProvider = "Rackspace"
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.name

  tags = merge(local.tags, var.tags)
}
