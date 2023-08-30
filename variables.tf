variable "docker_image" {
  description = "Base docker image to use."
  type        = string
}

variable "docker_tag" {
  description = "Tag of the docker image to use."
  type        = string
}

variable "cpu" {
  description = "CPU limits for container."
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory limits for container."
  type        = number
  default     = 512
}

variable "skip_destroy" {
  description = "Whether to retain the task definition revision when the resource is destroyed or replaced. Defaults to `false`."
  type        = bool
  default     = false
}

variable "service_environment_config" {
  description = "Service specific environment config"
  type        = list(map(string))
  default     = []
}

variable "service_secrets_config" {
  description = "Service specific environment secrets"
  type        = list(map(string))
  default     = []
}

variable "service_name" {
  description = "Name of the service to create."
  type        = string
}

variable "service_count" {
  description = "Number of replicas of the service to create. Defaults to 1."
  type        = number
  default     = 1
}

variable "deployment_maximum_percent" {
  description = "Maximum deployment as a percentage of `service_count`. Defaults to 200, for zero-downtime deployment."
  type        = number
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum healthy percentage for a deployment. Defaults to 100, for zero-downtime deployment."
  type        = number
  default     = 100
}

variable "container_port" {
  description = "Port the container should expose."
  type        = number
  default     = null
}

variable "cluster_name" {
  description = "Name of the ECS Cluster to deploy the service into."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs to place the service into."
  type        = list(string)
  default     = null
}

variable "tags" {
  description = "A map of tags to apply to all resources in this module."
  type        = map(string)
  default     = {}
}

variable "wait_for_steady_state" {
  description = "Whether to wait for the service to become stable akin to `aws ecs wait services-stable`. Defaults to true."
  type        = bool
  default     = true
}

variable "max_capacity" {
  description = "A maximum capacity for autoscaling."
  type        = number
}

variable "min_capacity" {
  description = "A minimum capacity for autoscaling. Defaults to 1."
  type        = number
  default     = 1
}

variable "autoscaling_metrics" {
  description = "A map of autoscaling metrics."
  type = map(object({
    metric_type        = string
    target_value       = number
    scale_in_cooldown  = number
    scale_out_cooldown = number
  }))
  default = {
    cpu = {
      metric_type        = "ECSServiceAverageCPUUtilization"
      target_value       = 75
      scale_in_cooldown  = 300
      scale_out_cooldown = 300
    },
    memory = {
      metric_type        = "ECSServiceAverageMemoryUtilization"
      target_value       = 75
      scale_in_cooldown  = 300
      scale_out_cooldown = 300
    }
  }
}

variable "target_group_arn" {
  description = "ARN of the load balancer target group."
  type        = string
  default     = null
}

variable "security_groups" {
  description = "A list of security group IDs to asssociate with the service."
  type        = list(string)
  default     = null
}

variable "cloudwatch_log_group_name" {
  description = "CloudWatch log group to use with the service."
  type        = string
  default     = null
}

variable "create_log_group" {
  description = "Whether to create the CloudWatch log group. Defaults to `true`."
  type        = bool
  default     = true
}

variable "execution_role_policy_arns" {
  description = "A list of additional policy ARNs to attach to the service's execution role."
  type        = list(string)
  default     = []
}

variable "task_role_policy_arns" {
  description = "A list of additional policy ARNs to attach to the service's task role."
  type        = list(string)
  default     = []
}

variable "timeout" {
  description = "Timeout time for the ECS service to become stable before producing a Terraform error."
  type        = string
  default     = "15m"
}

variable "private_dns_namespace" {
  description = "Private DNS namespace name. If provided, enables service discovery."
  type        = string
  default     = null
}

variable "network_mode" {
  description = "Docker networking mode to use. One of `awsvpc`, `bridge`, `host`, or `none`."
  type        = string
  default     = "awsvpc"
}

variable "use_fargate" {
  description = "Whether to use Fargate to launch tasks. Disable to use EC2-backed ECS."
  type        = bool
  default     = true
}

variable "fargate_version" {
  description = "Fargate platform version to use. Defaults to `LATEST`."
  type        = string
  default     = "LATEST"
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP to this service. Defaults to `false`."
  type        = bool
  default     = false
}

variable "use_autoscaling" {
  description = "Whether to use autoscaling for the service. Defaults to `false`."
  type        = bool
  default     = true
}

variable "entrypoint" {
  description = "Entrypoint to be passed to the container."
  type        = list(string)
  default     = null
}

variable "enable_ecs_exec" {
  description = "Whether to enable ECS Exec for the service."
  type        = bool
  default     = false
}

variable "healthcheck_grace_period" {
  description = "Number of seconds to wait before starting healthchecks on the service. Defaults to `10`."
  type        = number
  default     = 10
}

variable "enable_rollback" {
  description = "Whether to enable circuit breaker rollbacks. Defaults to `true`."
  type        = bool
  default     = true
}
