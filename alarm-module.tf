##
# (c) 2021-2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#
data "aws_sns_topic" "topic_destination" {
  count = try(var.alarms.enabled, false) ? 1 : 0
  name  = var.alarms.destination_topic
}


resource "aws_cloudwatch_metric_alarm" "metric_alarm" {
  count = try(var.alarms.enabled, false) ? 1 : 0

  alarm_name          = format("MetricsAlarm-%s-%s-%s", var.region, var.release.name, var.namespace)
  comparison_operator = "GreaterThanThreshold"
  statistic           = "Maximum"
  threshold           = var.alarms.threshold
  period              = var.alarms.period
  evaluation_periods  = var.alarms.evaluation_periods
  namespace           = "AWS/ElasticBeanstalk"
  metric_name         = "EnvironmentHealth"
  alarm_description   = "Metric Alarm for Beanstalk Application Health"
  actions_enabled     = true
  ok_actions = [
    data.aws_sns_topic.topic_destination[0].arn
  ]
  alarm_actions = [
    data.aws_sns_topic.topic_destination[0].arn
  ]
  dimensions = {
    EnvironmentName = module.app.environment_name
  }
  tags = merge(local.tags, module.tags.locals.common_tags)
}
