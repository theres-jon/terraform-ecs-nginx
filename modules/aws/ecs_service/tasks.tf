# Hardcoding this to Fargate for now
resource "aws_ecs_task_definition" "task_def" {
  family                   = var.name
  execution_role_arn       = var.task_execution_role_arn == "" ? var.task_execution_role_arn : aws_iam_role.task_execution_role[0].arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode(var.container_definition_json)

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-task-def",
    },
  )
}