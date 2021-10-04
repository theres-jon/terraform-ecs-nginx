resource "aws_iam_role" "ecs_task" {
  name                 = "${var.name}-nginx-ecs-demo"
  assume_role_policy   = data.aws_iam_policy_document.ecs_service_principal_allow.json
}

resource "aws_iam_role_policy" "task_run_as_def" {
  name   = "${var.name}-nginx-ecs-demo"
  role   = aws_iam_role.ecs_task.id
  policy = data.aws_iam_policy_document.task_permissions.json
}

data "aws_iam_policy_document" "ecs_service_principal_allow" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "task_permissions" {
  statement {
    effect = "Allow"

    resources = [
      "${aws_cloudwatch_log_group.ngingx_ecs_app.arn}:*",
    ]

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
}