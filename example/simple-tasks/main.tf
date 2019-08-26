variable "region" {}

provider "aws" {
  region = var.region
}

module "simple-task" {
  source = "../../"

  cluster_id     = "ecs-cluster-arena-staging"
  name_ecs_task  = "webgameapp-arena-staging"
  container_port = "80"

  tier         = "staging"
  organization = "arena"
}
