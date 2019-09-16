output "ecs_service_name" {
  value = element(concat(aws_ecs_service.this.*.name, list("")),0)
}

output "ecs_task_family_name" {
  value = element(concat(aws_ecs_task_definition.this.*.family, list("")), 0)
}

output "ecs_task_name" {
  value = local.name_ecs_task
}