data "aws_caller_identity" "current" {}

locals {
  name = "${var.environment}-nginx-ecs"

  default_tags = {
    environment = var.environment
    terraform = "true"
  }
}

module "vpc" {
  source = "./modules/aws/vpc"
  name   = local.name
  tags   = local.default_tags

  vpc_cidr_range = var.vpc_cidr_range
}

module "nginx_ecs_app" {
 source = "./modules/apps/nginx_ecs_app"
 name = local.name
 tags = local.default_tags
}

module "ecs_service" {
  source = "./modules/aws/ecs_service"
  name   = local.name
  tags   = local.default_tags

  vpc_id = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  public_subnet_ids = module.vpc.public_subnets
  ecs_cluster_id = aws_ecs_cluster.ecs_cluster.id

  container_definition_json = module.nginx_ecs_app.container_object
  container_name = module.nginx_ecs_app.container_name
  task_role_arn = module.nginx_ecs_app.task_role_arn

  depends_on = [module.vpc, module.nginx_ecs_app]

  route53_hosted_zone_domain_name = var.route53_hosted_zone_domain_name
  route53_hosted_zone_id = var.route53_hosted_zone_id
}
