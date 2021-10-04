# Terraform-Nginx-ECS Demo
This repository contains terraform that creates a demo application that hosts the nginx container in an ECS fargate task in AWS. 

What will be created is as follows - 
- VPC w/ Internet and NAT Gateways
- Security Groups
- Application Load Balancer
- ECS Task definition and Cluster
- Necessary IAM resources with minimal permissions

# How the repo is structured

## Running the code
The default profile from `~/.aws/credentials` is used, however, this can be overridden to provide any profile name you choose. 

Check `aws_profile` of `variables.tf` in the root folder.

*Please note that by default a VPC will be created with the CIDR 10.100.0.0/16 -  update if you wish to peer this VPC to another with overlapping addresses*

    > make apply

## Certificates
You have the option of passing in a Route 53 zone ID to use as a FQDN for cert creation. The `ecs_service` module will request a cert from ACM automatically and create the validation records. 

If no Route 53 zone is available - the app will listen on port 80 from the load balancer.

If a Route 53 zone is provided - the app will be available on 80 and 443 (80 will -> 443).

To do this - assign the proper values in the `./variables.tf` file.

*Example*

```
variable "route53_hosted_zone_domain_name" {
  description = "Provide the domain name to a zone that you own and have access to for a CNAME record and ACM cert to be created."
  type = string
  default = "theresjon.com"
}

variable "route53_hosted_zone_id" {
  description = "Provide the corresponding zone ID to be used for record creation."
  type = string
  default = "Z00998184RTY7A61947813D"
}
```

## Root
The root folder is representative of AWS resources that will be created for your environment. Consideration has been taken to separate environment specific resources from account specific resources.

These files could be moved to a separate `environment` folder in which they're applied across multiple environments and reused.

The main `Terraform` code in this module is simply implementing `modules` from the `Modules` folder below. The only resource that is not modularized is the ECS cluster itself which is lightweight enough that modularizing it would be superfluous. 

## Modules

#### Apps
The apps folder contains `nginx_ecs_app` which is a module that creates resources necessary to deploy the nginx app itself. This is decoupled from the `ecs_service` as `ecs_service` is intended to be generic.

#### AWS
The `ecs_service` folder contains the bulk of the work to get our application environment running. It takes parameters to create a service running on a cluster with an ALB to front it. 

The `vpc` folder simply creates a normalized VPC for our deployment to reside in. We'll have 3 public and 3 private subnets with associated internet and nat gateways.

## Open Items
Terraform state is intentionally set to run locally. As Terraform remote state requires a bucket to already exist, it's intentionally left open to the consumer of this code to implement remote state if they desire. 

The following code should be placed into `main.tf` of the root folder. 

```
terraform {
  backend "s3" {
    bucket = "<INSERT_YOUR_BUCKET_NAME_HERE>"
    key    = "terraform-nginx-ecs.tfstate"
    region = "us-east-1"
  }
}
```
