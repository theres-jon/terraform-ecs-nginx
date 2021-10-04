output "task_role_arn" {
    value = aws_iam_role.ecs_task.arn
}

output container_object {
    value = local.container_object
}

output container_name {
    value = local.container_name
}