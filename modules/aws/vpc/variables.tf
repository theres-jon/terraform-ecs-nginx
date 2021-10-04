variable "name" {
  description = "Used as a prefix for our naming convention of resources."
  type        = string
}

variable "vpc_cidr_range" {
  description = "Provides the CIDR range for the new VPC that will be created."
  type = string
}

variable "tags" {
  type = map(string)
  description = "Tags to be applied to the module resources."
}