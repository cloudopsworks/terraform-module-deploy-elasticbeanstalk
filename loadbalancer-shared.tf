##
# (c) 2021-2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#
# Module to manage the association of the DNS record with the shared load balancer

data "aws_lb" "shared_lb" {
  count = try(var.beanstalk.load_balancer.shared.enabled, false) ? 1 : 0
  name  = var.beanstalk.load_balancer.shared.name
}

module "app_dns_shared" {
  count                    = try(var.beanstalk.load_balancer.shared.enabled, false) && try(var.beanstalk.load_balancer.shared.dns.enabled, false) ? 1 : 0
  source                   = "cloudopsworks/beanstalk-dns/aws"
  version                  = "1.0.5"
  region                   = var.region
  sts_assume_role          = var.sts_assume_role
  release_name             = var.release.name
  namespace                = var.namespace
  private_domain           = try(var.dns.private_zone, false)
  domain_name              = var.dns.domain_name
  domain_name_alias_prefix = var.dns.alias_prefix
  domain_alias             = true
  alias_cname              = data.aws_lb.shared_lb[0].dns_name
  alias_zone_id            = data.aws_lb.shared_lb[0].zone_id
  #health_check_id          = try(aws_route53_health_check.health_a[0].id, "")
}