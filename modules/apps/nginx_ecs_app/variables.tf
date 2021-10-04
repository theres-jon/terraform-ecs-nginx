variable "name" {
    description = "Name of the application resources to create."
    type = string
}

variable "tags" {
  type = map(string)
  description = "Tags to be applied to the module resources."
}