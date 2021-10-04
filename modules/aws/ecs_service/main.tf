data "aws_route53_zone" "dns_zone" {
  count = var.route53_hosted_zone_id == "" ? 0 : 1
  
  zone_id = var.route53_hosted_zone_id
}

resource "aws_ecs_service" "ecs_service" {
  name                               = var.name
  cluster                            = var.ecs_cluster_id
  task_definition                    = aws_ecs_task_definition.task_def.arn
  desired_count                      = var.desired_count
  launch_type                        = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_service.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_alb.arn
    container_name   = var.container_name
    container_port   = 80
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-ecs-service",
    },
  )

  depends_on = [
    aws_lb.ecs_alb,
    aws_lb_target_group.ecs_alb
  ]
}

resource "aws_lb" "ecs_alb" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_service.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-alb",
    },
  )
}

resource "aws_lb_target_group" "ecs_alb" {
  name        = var.name
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  port        = 80
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-alb-tg"
    },
  )
}

# If no domain is provided, listen on 80
resource "aws_lb_listener" "ecs_alb_insecure" {
  count = var.route53_hosted_zone_domain_name == "" ? 1 : 0

  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_alb.arn
  }
}

# If a domain is provided, request cert, listen on 443
resource "aws_lb_listener" "ecs_alb_secure" {
  count = var.route53_hosted_zone_domain_name == "" ? 0 : 1

  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert[0].arn


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_alb.arn
  }
}

# If a domain is provided, redirect 80 to 443
resource "aws_lb_listener" "ecs_alb_redirect" {
  count = var.route53_hosted_zone_domain_name == "" ? 0 : 1

  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# If a domain is provided, request a cert for our app
resource "aws_acm_certificate" "cert" {
  count = var.route53_hosted_zone_domain_name == "" ? 0 : 1

  domain_name       = "nginx-ecs-demo-app.${var.route53_hosted_zone_domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-alb-tg"
    },
  )
}

# If a domain is provided, we need to create the 
# A records to validate the ACM request
resource "aws_route53_record" "cert" {
  count = var.route53_hosted_zone_domain_name == "" ? 0 : 1

  allow_overwrite = true
  name            = tolist(aws_acm_certificate.cert[0].domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.cert[0].domain_validation_options)[0].resource_record_value]
  ttl             = 60
  type            = tolist(aws_acm_certificate.cert[0].domain_validation_options)[0].resource_record_type
  zone_id         = data.aws_route53_zone.dns_zone[0].zone_id
}

resource "aws_route53_record" "public_dns_cname" {
  count = var.route53_hosted_zone_domain_name == "" ? 0 : 1

  allow_overwrite = true
  name            = "nginx-ecs-demo-app.${var.route53_hosted_zone_domain_name}"
  records         = [aws_lb.ecs_alb.dns_name]
  ttl             = 60
  type            = "CNAME"
  zone_id         = data.aws_route53_zone.dns_zone[0].zone_id
}