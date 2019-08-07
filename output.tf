output "ecs_service_name" {
  value = "${element(concat(aws_ecs_service.this.*.name, list("")),0)}"
}
