## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app"></a> [app](#module\_app) | cloudopsworks/beanstalk-deploy/aws | 1.0.15 |
| <a name="module_app_dns_shared"></a> [app\_dns\_shared](#module\_app\_dns\_shared) | cloudopsworks/beanstalk-dns/aws | 1.0.5 |
| <a name="module_dns"></a> [dns](#module\_dns) | cloudopsworks/beanstalk-dns/aws | 1.0.5 |
| <a name="module_tags"></a> [tags](#module\_tags) | cloudopsworks/tags/local | 1.0.9 |
| <a name="module_version"></a> [version](#module\_version) | cloudopsworks/beanstalk-version/aws | 1.0.13 |

## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_vpc_link.apigw_rest_link](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_vpc_link) | resource |
| [aws_cloudwatch_metric_alarm.metric_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_lb.apigw_rest_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.apigw_rest_lb_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.apigw_rest_lb_listener_link](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.apigw_rest_lb_tg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group.apigw_rest_lb_tg_link](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.apigw_rest_lb_tg_att](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_lb_target_group_attachment.apigw_rest_lb_tg_att_link](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_lb.apigw_rest_lb_link](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |
| [aws_lb.shared_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_sns_topic.topic_destination](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/sns_topic) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_absolute_path"></a> [absolute\_path](#input\_absolute\_path) | Absolute path to the configuration files | `string` | `""` | no |
| <a name="input_alarms"></a> [alarms](#input\_alarms) | Alarms configuration for the environment | `any` | `{}` | no |
| <a name="input_api_gateway"></a> [api\_gateway](#input\_api\_gateway) | API Gateway configuration for the environment | `any` | `{}` | no |
| <a name="input_beanstalk"></a> [beanstalk](#input\_beanstalk) | Beanstalk environment configuration | `any` | n/a | yes |
| <a name="input_dns"></a> [dns](#input\_dns) | DNS configuration for environment | `any` | `{}` | no |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_is_hub"></a> [is\_hub](#input\_is\_hub) | Establish this is a HUB or spoke configuration | `bool` | `false` | no |
| <a name="input_logs_bucket"></a> [logs\_bucket](#input\_logs\_bucket) | S3 bucket for application logs | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Environment namespace | `string` | n/a | yes |
| <a name="input_org"></a> [org](#input\_org) | n/a | <pre>object({<br>    organization_name = string<br>    organization_unit = string<br>    environment_type  = string<br>    environment_name  = string<br>  })</pre> | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_release"></a> [release](#input\_release) | Release configuration | `any` | n/a | yes |
| <a name="input_repository_owner"></a> [repository\_owner](#input\_repository\_owner) | GitHub repository owner | `string` | n/a | yes |
| <a name="input_spoke_def"></a> [spoke\_def](#input\_spoke\_def) | n/a | `string` | `"001"` | no |
| <a name="input_sts_assume_role"></a> [sts\_assume\_role](#input\_sts\_assume\_role) | STS Assume Role ARN | `string` | `null` | no |
| <a name="input_versions_bucket"></a> [versions\_bucket](#input\_versions\_bucket) | S3 bucket for application versions | `string` | n/a | yes |

## Outputs

No outputs.
