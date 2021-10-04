variable "environment" {
  description = "Used as a prefix for our naming convention of resources."
  type        = string
  default     = "demo"
}

variable "aws_profile" {
  description = "The AWS profile name that you'd like to run terraform as."
  type        = string
  default     = "default"
}

variable "aws_region" {
  description = "The region to deploy our resources - currently we don't support multi regional environments for this deployment."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_range" {
  description = "Provides the CIDR range for the new VPC that will be created."
  type        = string
  default     = "10.100.0.0/16"
}

variable "route53_hosted_zone_domain_name" {
  description = "Provide the domain name to a zone that you own and have access to for a CNAME record and ACM cert to be created."
  type = string
  default = ""
}

variable "route53_hosted_zone_id" {
  description = "Provide the corresponding zone ID to be used for record creation."
  type = string
  default = ""
}