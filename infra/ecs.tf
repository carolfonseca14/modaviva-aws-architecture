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
resource "aws_ecs_task_definition" "modaviva_api" {
  family                   = "modaviva-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_execution.arn
  task_role_arn      = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "modaviva-api"
      image     = "436847501474.dkr.ecr.us-east-1.amazonaws.com/modaviva-api:latest"
      essential = true

      cpu = 0

      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "DATABASE_PORT"
          value = "5432"
        },
        {
          name  = "DATABASE_HOST"
          value = "modaviva-db.cwr2eko8km1q.us-east-1.rds.amazonaws.com"
        },
        {
          name  = "DATABASE_NAME"
          value = "postgres"
        }
      ]

      secrets = [
        {
          name      = "DATABASE_USER"
          valueFrom = "arn:aws:secretsmanager:us-east-1:436847501474:secret:rds!db-2f0d7713-1438-449b-a12f-a8665311812b-lXPyeF:username::"
        },
        {
          name      = "DATABASE_PASSWORD"
          valueFrom = "arn:aws:secretsmanager:us-east-1:436847501474:secret:rds!db-2f0d7713-1438-449b-a12f-a8665311812b-lXPyeF:password::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = "/ecs/modaviva-api"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
