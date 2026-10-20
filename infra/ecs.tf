resource "aws_ecs_cluster" "modaviva" {
  name = "modaviva-cluster"
}

resource "aws_ecs_service" "modaviva_api" {
  name            = "modaviva-api-service"
  cluster         = aws_ecs_cluster.modaviva.id
  task_definition = "modaviva-api:4"
  desired_count   = 0
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [
      aws_subnet.private_a.id,
      aws_subnet.private_b.id
    ]

    security_groups = [
      aws_security_group.ecs.id
    ]

    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.modaviva_api.arn
    container_name   = "modaviva-api"
    container_port   = 8000
  }

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }
}

