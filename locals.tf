locals {
  cluster_arn    = data.aws_ecs_cluster.this.arn
  account_id     = data.aws_caller_identity.this.account_id
  region         = data.aws_region.this.name
  log_group      = try(data.aws_cloudwatch_log_group.this[0].name, aws_cloudwatch_log_group.this[0].name)
  log_group_name = try(var.cloudwatch_log_group_name, "${var.service_name}-log-group")

  default_environment_config = []
  default_secrets_config     = []

  merged_secrets = distinct(
    concat(
      var.service_secrets_config,
      local.default_secrets_config
    )
  )

  merged_environment = distinct(
    concat(
      var.service_environment_config,
      local.default_environment_config
    )
  )

  tags = merge(
    {
      Terraform = "true"
    },
    var.tags,
  )

}
