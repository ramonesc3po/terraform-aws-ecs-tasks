data "aws_ecs_cluster" "this" {
  cluster_name = var.cluster_id
}

locals {
  commmon_tags = {
    Organization = "${var.organization}"
    Tier         = "${var.tier}"
    Terraform    = "true"
  }

  name_ecs_task = "${var.name_ecs_task}-${var.tier}"

  name_ecs_service = "service-${local.name_ecs_task}"
}

locals {
  default_json = <<EOF
  [
  {
    "name": "${local.name_ecs_task}",
    "image": "nginx",
    "cpu": 1,
    "memory": 64,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "protocol": "tcp"
      }
    ],
    "Environment" : [
      {
        "Name": "SERVER_NAME",
        "Value": "localhost"
      }
    ]
  }
  ]
  EOF
}

resource "aws_ecs_task_definition" "this" {
  container_definitions = var.ecs_container_definitions == "" ? local.default_json : var.ecs_container_definitions
  family                = local.name_ecs_task

  requires_compatibilities = ["EC2"]

  execution_role_arn = aws_iam_role.ecs_exec_this.arn
  task_role_arn      = aws_iam_role.ecs_task_this.arn

  ipc_mode = var.ipc_mode

  dynamic "placement_constraints" {
    for_each = [for placements in var.placement_constraints : {
      type       = placements.type
      expression = placements.expression
    }]
    content {
      type       = placement_constraints.value.type
      expression = placement_constraints.value.expression
    }
  }

  dynamic "volume" {
    for_each = [for volumes in var.volumes : {
      name                        = volumes.name
      host_path                   = volumes.host_path
    } if var.volumes.0.name != null ]
    content {
      name                        = volume.value.name
      host_path                   = volume.value.host_path
    }
  }

  network_mode = var.network_mode

  tags = merge(local.commmon_tags, var.tags, { "Name" = local.name_ecs_task })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_service" "this" {
  count           = 1
  name            = local.name_ecs_task
  task_definition = aws_ecs_task_definition.this.arn
  cluster         = data.aws_ecs_cluster.this.id

  desired_count = var.desired_count

  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"
  launch_type                        = "EC2"
  scheduling_strategy                = var.service_scheduling_strategy
  health_check_grace_period_seconds  = var.lb_target_group_name[0] != null ? 120 : null

  deployment_controller {
    type = "ECS"
  }

  dynamic "load_balancer" {
    for_each = var.lb_target_group_name[0] != null ? var.lb_target_group_name : []
    content {
      target_group_arn = load_balancer.value[0]
      container_name   = load_balancer.value[1]
      container_port   = load_balancer.value[2]
    }
  }

  tags = merge(local.commmon_tags, var.tags, { "Name" = local.name_ecs_service })

  lifecycle {
    ignore_changes = [
      "desired_count",
    ]

    create_before_destroy = true
  }
}

#
# REFATORAR
#

locals {
  name_role_ecs_exec = "ecs-exec-${local.name_ecs_task}"
  name_role_ecs_task = "ecs-task-${local.name_ecs_task}"
}

resource "aws_iam_role" "ecs_exec_this" {
  name               = "${local.name_role_ecs_exec}"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_task_exec.json}"

  tags = "${merge(local.commmon_tags, var.tags, map("Name", local.name_role_ecs_exec))}"
}

data "aws_iam_policy_document" "ecs_exec" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
}

data "aws_iam_policy_document" "ecs_task" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_this" {
  name               = "${local.name_role_ecs_task}"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_task.json}"

  tags = "${merge(local.commmon_tags, var.tags, map("Name", local.name_role_ecs_task))}"
}

# IAM role that the Amazon ECS container agent and the Docker daemon can assume
data "aws_iam_policy_document" "ecs_task_exec" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_exec_container_role" {
  role       = "${aws_iam_role.ecs_exec_this.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_exec_cloudwatch_role" {
  role       = "${aws_iam_role.ecs_exec_this.id}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_task_container_role" {
  role       = "${aws_iam_role.ecs_task_this.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_task_cloudwatch_role" {
  role       = "${aws_iam_role.ecs_task_this.id}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
