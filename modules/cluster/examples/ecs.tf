provider "aws" {
  version = "~> 1.2"
  region  = "us-west-2"
}

resource "random_string" "ecs_rstring" {
  length  = 18
  upper   = false
  special = false
}

module "ecs" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ecs//?ref=v0.0.1"

  cluster_name = "MyCluster"
}
