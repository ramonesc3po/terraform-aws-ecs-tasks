variable "region" {}

provider "aws" {
  region = var.region
}

module "simple-task" {
  source = "../../"

  cluster_id     = "ecs-cluster-id"
  name_ecs_task  = "simple-task"
  service_scheduling_strategy = "REPLICA"

  volumes = [
    {
      name = "tmp"
      host_path = "/tmp"
    }
  ]

  tier         = "staging"
  organization = "arena"
}
