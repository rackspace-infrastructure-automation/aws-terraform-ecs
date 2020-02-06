provider "aws" {
  region  = "us-west-2"
  version = "~> 2.1"
}

module "ecs" {
  source = "../../module/modules/cluster"

  name = "MyCluster"

  tags = {
    Environment = "Test"
  }
}
