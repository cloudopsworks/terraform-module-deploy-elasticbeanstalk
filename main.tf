##
# (c) 2021-2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#
locals {
  tags = merge(var.extra_tags, {
    Environment = format("%s-%s", var.release.name, var.namespace)
    Namespace   = var.namespace
    Release     = var.release.name
  })
}
##
# This module to manage DNS association.
#   - This can be commented out to disable DNS management (not recommended)
#
module "dns" {
  count                    = try(var.beanstalk.load_balancer.shared.enabled, false) ? 0 : 1
  source                   = "cloudopsworks/beanstalk-dns/aws"
  version                  = "1.0.5"
  region                   = var.region
  sts_assume_role          = var.sts_assume_role
  release_name             = var.release.name
  namespace                = var.namespace
  private_domain           = var.dns.private_zone
  domain_name              = var.dns.domain_name
  domain_name_alias_prefix = var.dns.alias_prefix
  domain_alias             = true
  alias_cname              = module.app.environment_cname
  alias_zone_id            = module.app.environment_zone_id
}

module "version" {
  source          = "cloudopsworks/beanstalk-version/aws"
  version         = "1.0.12"
  region          = var.region
  sts_assume_role = var.sts_assume_role

  release_name     = var.release.name
  source_name      = var.release.source.name
  source_version   = var.release.source.version
  namespace        = var.namespace
  solution_stack   = var.beanstalk.solution_stack
  repository_owner = var.repository_owner
  # Uncomment below to override the default source for the solution stack
  #   Supported source_compressed_type: zip, tar, tar.gz, tgz, tar.bz, tar.bz2, etc.
  force_source_compressed = can(var.release.source.force_compressed) ? var.release.source.force_compressed : false
  source_compressed_type  = can(var.release.source.compressed_type) ? var.release.source.compressed_type : "zip"

  application_versions_bucket = var.versions_bucket

  beanstalk_application = var.beanstalk.application
  config_source_folder  = var.absolute_path == "" ? format("%s/%s", "values", var.release.name) : format("%s/%s/%s", var.absolute_path, "values", var.release.name)
  config_hash_file      = var.absolute_path == "" ? format("%s_%s", ".values_hash", var.release.name) : format("%s/%s_%s", var.absolute_path, ".values_hash", var.release.name)

  github_package = try(var.release.source.githubPackages.name, "") != "" && try(var.release.source.githubPackages.type, "") != ""
  package_name   = try(var.release.source.githubPackages.name, "")
  package_type   = try(var.release.source.githubPackages.type, "")

  extra_run_command = try(var.release.extra_run_command, "")
}

module "app" {
  source          = "cloudopsworks/beanstalk-deploy/aws"
  version         = "1.0.15"
  region          = var.region
  sts_assume_role = var.sts_assume_role

  release_name   = var.release.name
  namespace      = var.namespace
  solution_stack = var.beanstalk.solution_stack

  application_version_label = module.version.application_version_label

  private_subnets = var.beanstalk.networking.private_subnets
  public_subnets  = var.beanstalk.networking.public_subnets
  vpc_id          = var.beanstalk.networking.vpc_id
  server_types    = var.beanstalk.instance.server_types

  beanstalk_application          = var.beanstalk.application
  beanstalk_ec2_key              = can(var.beanstalk.instance.ec2_key) ? var.beanstalk.instance.ec2_key : null
  beanstalk_ami_id               = can(var.beanstalk.instance.ami_id) ? var.beanstalk.instance.ami_id : null
  beanstalk_instance_port        = var.beanstalk.instance.instance_port
  beanstalk_enable_spot          = var.beanstalk.instance.enable_spot
  beanstalk_default_retention    = var.beanstalk.instance.default_retention
  beanstalk_instance_volume_size = var.beanstalk.instance.volume_size
  beanstalk_instance_volume_type = var.beanstalk.instance.volume_type
  beanstalk_instance_profile     = can(var.beanstalk.iam.instance_profile) ? var.beanstalk.iam.instance_profile : null
  beanstalk_service_role         = can(var.beanstalk.iam.service_role) ? var.beanstalk.iam.service_role : null
  beanstalk_min_instances        = try(var.beanstalk.instance.pool.min, 1)
  beanstalk_max_instances        = try(var.beanstalk.instance.pool.max, 1)

  load_balancer_shared             = try(var.beanstalk.load_balancer.shared.enabled, false)
  load_balancer_shared_name        = try(var.beanstalk.load_balancer.shared.name, "")
  load_balancer_shared_weight      = try(var.beanstalk.load_balancer.shared.weight, 100)
  load_balancer_public             = var.beanstalk.load_balancer.public
  load_balancer_log_bucket         = var.logs_bucket
  load_balancer_log_prefix         = var.release.name
  load_balancer_ssl_certificate_id = var.beanstalk.load_balancer.ssl_certificate_id
  load_balancer_ssl_policy         = can(var.beanstalk.load_balancer.ssl_policy) ? var.beanstalk.load_balancer.ssl_policy : null
  load_balancer_alias              = can(var.beanstalk.load_balancer.alias) ? var.beanstalk.load_balancer.alias : null

  port_mappings  = var.beanstalk.port_mappings
  rule_mappings  = try(var.beanstalk.rule_mappings, [])
  extra_tags     = merge(try(var.beanstalk.extra_tags, {}), module.tags.locals.common_tags)
  extra_settings = var.beanstalk.extra_settings
}
