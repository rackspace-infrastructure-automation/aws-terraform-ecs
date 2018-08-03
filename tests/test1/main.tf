provider "aws" {
  version = "~> 1.2"
  region  = "us-west-2"
}

module "ecs" {
  source = "../../module"

  cluster_name = "MyCluster"
}
