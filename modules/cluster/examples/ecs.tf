terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region  = "us-west-2"
  version = "~> 3.0"
}

module "ecs" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ecs//modules/cluster/?ref=v0.12.2"

  name = "MyCluster"

  tags = {
    Terraform = "true"
  }
}
