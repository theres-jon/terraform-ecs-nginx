resource "aws_cloudwatch_log_group" "ngingx_ecs_app" {
  name              = var.name
  retention_in_days = 30

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-vpc",
    },
  )
}