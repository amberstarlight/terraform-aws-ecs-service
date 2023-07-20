data "aws_availability_zones" "this" {}

locals {
  region = "eu-west-2"
  cidr   = "10.0.0.0/16"
  azs    = slice(data.aws_availability_zones.this.names, 0, 3)
}
