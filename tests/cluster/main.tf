provider "aws" {
  version = ">= 2.1.0"
  region  = "us-west-2"
}

module "ecs" {
  source = "../../module/modules/cluster"

  cluster_name = "MyCluster"

  tags = {
    Environment = "Test"
  }
}
