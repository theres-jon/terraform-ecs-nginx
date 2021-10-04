output "public_lb_dns_name" {
    value = aws_lb.ecs_alb.dns_name
}

output "public_https_link" {
    value = var.route53_hosted_zone_domain_name == "" ? "" : "nginx-ecs-demo-app.${var.route53_hosted_zone_domain_name}"
}