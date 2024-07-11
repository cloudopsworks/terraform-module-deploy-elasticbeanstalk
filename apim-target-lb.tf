##
# (c) 2021-2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

## API GATEWAY LINK ENABLED only
# Will create all new link and NLB for the beanstalk environment.
# If you want to use an existing NLB, use the `vpc_link.use_existing = true` option
resource "aws_api_gateway_vpc_link" "apigw_rest_link" {
  count = try(var.api_gateway.enabled, false) && try(!var.api_gateway.vpc_link.use_existing, true) ? 1 : 0

  name        = try(var.api_gateway.vpc_link.link_name, "api-gw-nlb-${lower(var.release.name)}-${var.namespace}-nlb-link")
  description = "VPC Link for API Gateway to NLB: api-gw-nlb-${lower(var.release.name)}-${var.namespace}"
  target_arns = [aws_lb.apigw_rest_lb[0].arn]
  tags        = merge(local.tags, module.tags.locals.common_tags)
}

#resource "aws_apigatewayv2_vpc_link" "apigw_http_link" {
#  count = ry(var.api_gateway.enabled, false) && try(!var.api_gateway.vpc_link.use_existing, true) ? 1 : 0
#
#  name = "api-${lower(var.release.name)}-${var.namespace}-vpc-link"
#  subnet_ids = var.beanstalk.networking.private_subnets
#  security_group_ids = []
#  tags = local.tags
#}

resource "aws_lb" "apigw_rest_lb" {
  count              = try(var.api_gateway.enabled, false) && try(!var.api_gateway.vpc_link.use_existing, true) ? 1 : 0
  name               = "api-gw-nlb-${lower(var.release.name)}-${var.namespace}"
  internal           = !var.beanstalk.load_balancer.public
  load_balancer_type = "network"
  subnets            = var.beanstalk.load_balancer.public ? var.beanstalk.networking.public_subnets : var.beanstalk.networking.private_subnets
  tags               = merge(local.tags, module.tags.locals.common_tags)
}

resource "aws_lb_target_group" "apigw_rest_lb_tg" {
  count       = try(var.api_gateway.enabled, false) && try(!var.api_gateway.vpc_link.use_existing, true) ? 1 : 0
  name        = "tg-${lower(var.release.name)}-${var.namespace}-443"
  target_type = "alb"
  protocol    = "TCP"
  port        = 443
  vpc_id      = var.beanstalk.networking.vpc_id

  health_check {
    enabled  = try(var.api_gateway.vpc_link.health.enabled, false)
    protocol = try(var.api_gateway.vpc_link.health.protocol, "TCP")
    matcher  = try(var.api_gateway.vpc_link.health.http_status, "")
    path     = try(var.api_gateway.vpc_link.health.path, "")
  }

  tags = merge(local.tags, module.tags.locals.common_tags)
}

resource "aws_lb_target_group_attachment" "apigw_rest_lb_tg_att" {
  count            = try(var.api_gateway.enabled, false) && try(!var.api_gateway.vpc_link.use_existing, true) ? 1 : 0
  target_group_arn = aws_lb_target_group.apigw_rest_lb_tg[0].arn
  target_id        = module.app.load_balancer_id
}

resource "aws_lb_listener" "apigw_rest_lb_listener" {
  count             = try(var.api_gateway.enabled, false) && try(!var.api_gateway.vpc_link.use_existing, true) ? 1 : 0
  load_balancer_arn = aws_lb.apigw_rest_lb[0].arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.apigw_rest_lb_tg[0].arn
  }
  tags = merge(local.tags, module.tags.locals.common_tags)
}

## EXISTING NLB
# api_gateway:
#   vpc_link:
#     use_existing: true

data "aws_lb" "apigw_rest_lb_link" {
  count = try(var.api_gateway.enabled, false) && try(var.api_gateway.vpc_link.use_existing, false) ? 1 : 0
  name  = var.api_gateway.vpc_link.lb_name
}

resource "aws_lb_target_group" "apigw_rest_lb_tg_link" {
  count       = try(var.api_gateway.enabled, false) && try(var.api_gateway.vpc_link.use_existing, false) ? 1 : 0
  name        = "tg-${lower(var.release.name)}-${var.namespace}-${var.api_gateway.vpc_link.listener_port}"
  target_type = "alb"
  protocol    = "TCP"
  port        = try(var.api_gateway.vpc_link.to_port, var.api_gateway.vpc_link.listener_port)
  vpc_id      = var.beanstalk.networking.vpc_id

  health_check {
    enabled  = true
    protocol = try(var.api_gateway.vpc_link.health.protocol, "TCP")
    matcher  = try(var.api_gateway.vpc_link.health.http_status, "")
    path     = try(var.api_gateway.vpc_link.health.path, "")
  }
  tags = merge(local.tags, module.tags.locals.common_tags)
}

resource "aws_lb_target_group_attachment" "apigw_rest_lb_tg_att_link" {
  count            = try(var.api_gateway.enabled, false) && try(var.api_gateway.vpc_link.use_existing, false) ? 1 : 0
  target_group_arn = aws_lb_target_group.apigw_rest_lb_tg_link[0].arn
  target_id        = module.app.load_balancer_id
}


resource "aws_lb_listener" "apigw_rest_lb_listener_link" {
  count             = try(var.api_gateway.enabled, false) && try(var.api_gateway.vpc_link.use_existing, false) ? 1 : 0
  load_balancer_arn = data.aws_lb.apigw_rest_lb_link[0].arn
  port              = var.api_gateway.vpc_link.listener_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.apigw_rest_lb_tg_link[0].arn
  }
  tags = merge(local.tags, module.tags.locals.common_tags)

  lifecycle {
    replace_triggered_by = [aws_lb_target_group.apigw_rest_lb_tg_link[0]]
  }
}
