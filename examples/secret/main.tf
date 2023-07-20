module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"

  name = "cool-vpc"
  cidr = local.cidr
  azs  = local.azs

  private_subnets = [
    for k, v in local.azs : cidrsubnet(local.cidr, 4, k)
  ]
}

resource "aws_ecs_cluster" "this" {
  name = "ecs-cluster"
}

# A secret created elsewhere
data "aws_secretsmanager_secret" "api_token" {
  name = "api-token-secret"
}

module "service" {
  source = "../../"

  service_name = "webserver"
  cluster_name = aws_ecs_cluster.this.name

  docker_image   = "nginx"
  docker_tag     = "stable"
  max_capacity   = 5
  container_port = 8080

  subnet_ids = module.vpc.private_subnets

  execution_role_policy_arns = [
    aws_iam_policy.secrets.arn
  ]

  service_environment_config = [
    {
      name  = "COOL_FEATURE_ENABLED"
      value = "true"
    }
  ]

  service_secrets_config = [
    {
      name      = "SERVICE_API_TOKEN"
      valueFrom = data.aws_secretsmanager_secret.api_token.arn
    }
  ]
}
