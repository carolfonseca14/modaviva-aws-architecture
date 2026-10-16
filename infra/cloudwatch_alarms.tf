resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "modaviva-ecs-cpu-high"
  alarm_description   = "CPU m\u00e9dia do servi\u00e7o ECS acima de 80% por 5 minutos"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = "modaviva-cluster"
    ServiceName = "modaviva-api-service"
  }

  alarm_actions = [aws_sns_topic.cloudwatch_alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  alarm_name          = "modaviva-ecs-memory-high"
  alarm_description   = "Mem\u00f3ria m\u00e9dia do servi\u00e7o ECS acima de 80% por 5 minutos"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = "modaviva-cluster"
    ServiceName = "modaviva-api-service"
  }

  alarm_actions = [aws_sns_topic.cloudwatch_alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "ecs_tasks_low" {
  alarm_name          = "modaviva-ecs-tasks-low"
  alarm_description   = "Quantidade de tarefas ECS abaixo de 2"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "LiveTaskCount"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 2
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = "modaviva-cluster"
    ServiceName = "modaviva-api-service"
  }

  alarm_actions = [aws_sns_topic.cloudwatch_alerts.arn]
}
