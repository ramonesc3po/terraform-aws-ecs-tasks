module "autoscaling" {
  source = "github.com/ramonesc3po/tf-aws-appautoscaling-policy-ecs-service.git?ref=develop"

  cluster_name = data.aws_ecs_cluster.this.cluster_name
  service_name = local.name_ecs_task
  resource_id  = aws_ecs_task_definition.this.id
  min_capacity = var.scale.min
  max_capacity = var.scale.max
}

module "alarm_scale" {
  source = "github.com/ramonesc3po/tf-aws-alarm-scale-ecs-service?ref=develop"

  service_name = local.name_ecs_task
  cluster_name = data.aws_ecs_cluster.this.cluster_name

  alarm_up_actions   = [module.autoscaling.appautoscaling_scale_up_policy_arn]
  alarm_down_actions = [module.autoscaling.appautoscaling_scale_down_policy_arn]

  cpu_scale_up_is_enabled    = true
  memory_scale_up_is_enabled = true
  scale_up = {
    cpu = {
      threshold = var.scale.limit.cpu
    }
    memory = {
      threshold = var.scale.limit.mem
    }
  }

  cpu_scale_down_is_enabled    = true
  memory_scale_down_is_enabled = true
}
