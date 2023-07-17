data "aws_ssm_parameter" "vpc_id" {
  name = "/vpc/vpc_id"
}

data "aws_ssm_parameter" "public_subnets" {
  name = "/vpc/public_subnets"
}
