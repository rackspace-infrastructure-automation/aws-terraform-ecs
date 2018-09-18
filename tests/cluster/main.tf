provider "aws" {
  version = "~> 1.2"
  region  = "us-west-2"
}

module "ecs" {
  source = "../../module/modules/cluster"

  cluster_name = "MyCluster"
}
