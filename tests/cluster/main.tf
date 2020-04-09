provider "aws" {
  region  = "us-west-2"
  version = "~> 2.7"
}

module "ecs" {
  source = "../../module/modules/cluster"

  name = "MyTestCluster"

  tags = {
    Environment = "Test"
  }
}
