provider "aws" {
  version = "~> 1.2"
  region  = "us-west-2"
}

module "ecs-cluster" "ecs-cluster" {
  source = "../../module/modules/cluster"

  cluster_name = "test_ecs_cluster"
}
