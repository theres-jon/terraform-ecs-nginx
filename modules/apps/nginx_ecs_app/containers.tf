data "aws_region" "current" {}

locals {
  container_name = "${var.name}-nginx"
  container_object = [
    {
      "name": local.container_name,
      "image": "nginx",
      "essential": true,
      "mountPoints": [],
      "environment": [],
      "portMappings": [
        {
          "hostPort": 80,
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "logConfiguration": {
        "logDriver" = "awslogs"
        "options"   = merge({
            "awslogs-group"         = aws_cloudwatch_log_group.ngingx_ecs_app.name
            "awslogs-region"        = data.aws_region.current.name
            "awslogs-stream-prefix" = "container"
          })
      },
    }
  ]
}
