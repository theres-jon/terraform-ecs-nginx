# If an execution ARN is not provided
# we'll create a basic role with ECR
# and log permissions and attempt to use it.
resource "aws_iam_role" "task_execution_role" {
    count = var.task_execution_role_arn == "" ? 0 : 1

    name = "${var.name}-ecs-execution-role"
    assume_role_policy = "${data.aws_iam_policy_document.task_execution_role.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_tasks_execution_role" {
  count = var.task_execution_role_arn == "" ? 0 : 1

  role       = aws_iam_role.task_execution_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "task_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}