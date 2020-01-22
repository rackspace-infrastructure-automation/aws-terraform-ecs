provider "aws" {
  version = ">= 2.1.0"
  region  = "us-west-2"
}

module "ecs" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ecs//modules/cluster/?ref=v0.0.3"

  cluster_name = "MyCluster"

  tags = {
    Terraform = "true"
  }
}

