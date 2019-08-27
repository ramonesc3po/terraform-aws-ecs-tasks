Terraform AWS Elastic Container Service Tasks
===

Developing

Example
---
```hcl
module "simple-task" {
  source = "../../"

  tier         = "staging"
  organization = "arena"
  cluster_id     = "ecs-cluster-id"
  name_ecs_task  = "simple-task"
  container_port = "80"
  service_scheduling_strategy = "REPLICA"
}
```

Author
---
Ramones C3po