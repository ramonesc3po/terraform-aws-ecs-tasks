variable "tags" {
  type = "map"

  default = {
    New = "null"
  }
}

variable "cluster_id" {}

variable "name_ecs_task" {}

variable "ecs_container_definitions" {
  default = ""
}

variable "container_port" {}

variable "organization" {}

variable "tier" {}

variable "service_scheduling_strategy" {
  default = "REPLICA"
}

variable "desired_count" {
  type    = number
  default = 0
}

##
# ECS Task Definitiion
##
variable "ipc_mode" {
  description = "(Optional) The IPC resource namespace to be used for the containers in the task The valid values are host, task, and none."
  type        = string
  default     = "none"
}

variable "network_mode" {
  type    = string
  default = "bridge"
}

variable "volumes" {
  type = list(object({
    name      = string
    host_path = string
    #    docker_volume_configuration = map(string)
  }))

  default = [{
    name      = null
    host_path = null
  }]
}

variable "placement_constraints" {
  type = list(object({
    type       = string
    expression = string
  }))

  default = [
    {
      type       = "memberOf"
      expression = "attribute:ecs.availability-zone in [us-east-1a, us-east-1b, us-east-1c, us-east-1d, us-east-1e, us-east-1f]"
    }
  ]
}

##
# ECS Service
##
variable "lb_target_group_name" {
  description = ""
  type = list(string)
  default = [null,null,null]
}