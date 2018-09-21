provider "aws" {
  version = "~> 1.2"
  region  = "us-west-2"
}

module "ecs" {
  source = "../../module/modules/cluster"

  ecs_cluster_name = "MyCluster"
}
