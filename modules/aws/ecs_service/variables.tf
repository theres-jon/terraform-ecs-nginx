variable "name" {
  description = "Used as a prefix for our naming convention of resources."
  type        = string
}

variable "tags" {
  type = map(string)
  description = "Tags to be applied to the module resources."
}

variable "vpc_id" {
  description = "The VPC to deploy our ECS resources into."
  type = string
}

variable "task_execution_role_arn" {
  description = "The ARN to use when executing our ECS tasks."
  type = string
  default = "AmazonECSTaskExecutionRolePolicy"
}

# This has to be passed in as this 
# module is intended to be somewhat
# generic in its implementation.
variable "task_role_arn" {
  description = "The ARN of the role the container will run as."
  type = string
}

variable container_definition_json {
  description = "The JSON representation of the container we're launching."
}

variable container_name {
  description = "Needs to match the container name in the task definition so it can attach to the load balancer"
  type = string
}

variable "ecs_cluster_id" {
  description = "Which ECS cluster to run the service on."
  type = string
}

variable "task_cpu" {
  description = "The amount of CPU capacity to assign to the task."
  type = number
  default = 512
}

variable "task_memory" {
  description = "The amount of memory capacity to assign to the task."
  type = number
  default = 1024
}

variable "desired_count" {
  description = "How many instances of the service should be running at any given time."
  type = number
  default = 1
}

variable "public_subnet_ids" {
  description = "The public subnets to place the ALB into."
  type = list(string)
}

variable "private_subnet_ids" {
  description = "The private subnets to place the task into."
  type = list(string)
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
