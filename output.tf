output "public_lb_dns_name" {
    value = module.ecs_service.public_lb_dns_name
}

output "public_https_link" {
    value = var.route53_hosted_zone_domain_name == "" ? "" : "https://${module.ecs_service.public_https_link}"
}