resource "aws_ecs_service" "this" {
  name             = var.service_name
  cluster          = local.cluster_arn
  task_definition  = aws_ecs_task_definition.this.arn
  desired_count    = var.service_count
  launch_type      = var.use_fargate ? "FARGATE" : "EC2"
  platform_version = var.use_fargate ? var.fargate_version : null

  dynamic "load_balancer" {
    for_each = var.target_group_arn != null ? [true] : []
    content {
      container_name   = var.service_name
      container_port   = var.container_port
      target_group_arn = var.target_group_arn
    }
  }

  dynamic "network_configuration" {
    for_each = var.network_mode == "awsvpc" && var.subnet_ids != null ? [true] : []
    content {
      assign_public_ip = var.use_fargate ? var.assign_public_ip : false
      security_groups  = var.security_groups
      subnets          = var.subnet_ids
    }
  }

  dynamic "service_registries" {
    for_each = var.private_dns_namespace != null ? [true] : []
    content {
      registry_arn   = aws_service_discovery_service.this[0].arn
      container_port = var.container_port
    }
  }

  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  wait_for_steady_state              = var.wait_for_steady_state

  timeouts {
    create = var.timeout
    update = var.timeout
    delete = var.timeout
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [
    aws_iam_role_policy_attachment.execution_role_policy,
    aws_iam_role_policy_attachment.task_role_policy
  ]

  tags = local.tags
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.service_name
  network_mode             = var.network_mode
  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
  skip_destroy             = var.skip_destroy
  requires_compatibilities = var.use_fargate ? ["FARGATE"] : ["EC2"]
  cpu                      = var.use_fargate ? var.cpu : null
  memory                   = var.use_fargate ? var.memory : null

  container_definitions = jsonencode([
    {
      name        = var.service_name
      image       = "${var.docker_image}:${var.docker_tag}"
      essential   = true
      environment = local.merged_environment
      secrets     = local.merged_secrets

      cpu    = var.use_fargate ? null : var.cpu
      memory = var.use_fargate ? null : var.memory

      entrypoint = var.entrypoint

      portMappings = [{
        protocol      = "tcp"
        containerPort = var.container_port
      }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = local.region
          awslogs-stream-prefix = "ecs"
          awslogs-group         = local.log_group
        }
      }
    }
  ])

  # TODO: allow users to specify platform
  dynamic "runtime_platform" {
    for_each = var.use_fargate ? [true] : [false]
    content {
      operating_system_family = "LINUX"
      cpu_architecture        = "X86_64"
    }
  }

  tags = local.tags
}

resource "aws_appautoscaling_target" "this" {
  count              = var.use_autoscaling ? 1 : 0
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "this" {
  for_each           = var.use_autoscaling ? var.autoscaling_metrics : {}
  name               = "${aws_ecs_service.this.name}-scaling-policy-${each.key}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = each.value.target_value
    scale_in_cooldown  = each.value.scale_in_cooldown
    scale_out_cooldown = each.value.scale_out_cooldown
    predefined_metric_specification {
      predefined_metric_type = each.value.metric_type
    }
  }

  depends_on = [aws_appautoscaling_target.this]
}

resource "aws_service_discovery_service" "this" {
  count = var.private_dns_namespace != null ? 1 : 0
  name  = var.service_name

  dns_config {
    namespace_id   = data.aws_service_discovery_dns_namespace.this[0].id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}
