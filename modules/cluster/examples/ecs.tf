provider "aws" {
  version = "~> 1.2"
  region  = "us-west-2"
}

module "ecs" {
  source = "github.com/rackspace-infrastructure-automation/aws-terraform-ecs//?ref=v0.0.1"

  cluster_name = "MyCluster"
}
