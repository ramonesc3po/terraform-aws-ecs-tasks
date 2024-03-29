##
# General
##
variable "tags" {
  type = "map"

  default = {
    New = "null"
  }
}

variable "cluster_id" {}

variable "organization" {}

variable "tier" {}

##
# ECS Task Definitiion
##
variable "name_ecs_task" {}

variable "ecs_container_definitions" {
  default = ""
}

variable "service_scheduling_strategy" {
  default = "REPLICA"
}

variable "desired_count" {
  type    = number
  default = 0
}

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
    #docker_volume_configuration = map(string)
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
  type = list(object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  }))
  default = [
    {
      target_group_arn = null
      container_name   = null
      container_port   = null
    }
  ]
}

##
# ECS Service scale
##
variable "scale" {
  type = object({
    max   = number
    min   = number
    limit = object({
      cpu = number
      mem = number
    })
  })

  default = {
    max = 10
    min = 1
    limit = {
      cpu = 80
      mem = 70
    }
  }
}