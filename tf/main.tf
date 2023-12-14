# main.tf

provider "aws" {
  region = "us-east-1"
}

# ALB
resource "aws_lb" "web" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = []

  enable_deletion_protection = false

  subnets = ["subnet-abc", "subnet-xyz"]

  enable_cross_zone_load_balancing = true

  enable_http2 = true
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "web-ecs-cluster"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "web" {
  family                   = "web-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = "arn:aws:iam::ACCOUNT_ID:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([
    {
      name  = "ready-app"
      image = "ready-app:latest"
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

# ECS Service with Rolling Deployment and Auto Scaling
resource "aws_ecs_service" "web" {
  name            = "web-ecs-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.web.arn
  launch_type     = "FARGATE"
  desired_count   = 2
  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    subnets         = ["subnet-xxxxxxxxxxxxxxx", "subnet-yyyyyyyyyyyyyyy"]
    security_groups = ["sg-xxxxxxxxxxxxxxxxx"]
  }

  # Enable Auto Scaling
  enable_ecs_managed_tags = true
  enable_execute_command  = true

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50
  health_check_grace_period_seconds  = 60
  wait_for_steady_state              = true
  force_new_deployment               = true

  depends_on = [aws_ecs_task_definition.web]
}

