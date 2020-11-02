provider "aws" {
  region  = "us-west-2"
  version = "~> 3.0"
}

module "ecs" {
  source = "../../module/modules/cluster"

  name = "MyTestCluster"

  tags = {
    Environment = "Test"
  }
}
