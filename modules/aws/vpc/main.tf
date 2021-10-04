data "aws_availability_zones" "azs" {}

locals{
    private_cidr_ranges = [for k,v in module.subnet_cidr_ranges.network_cidr_blocks : v if length(regexall("^priv*", k)) >0 ]
    public_cidr_ranges = [for k,v in module.subnet_cidr_ranges.network_cidr_blocks : v if length(regexall("^publ*", k)) >0 ]
}

module "subnet_cidr_ranges" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = var.vpc_cidr_range
  networks = [
    {
      name     = "private_subnet_1"
      new_bits = 4
    },
    {
      name     = "private_subnet_2"
      new_bits = 4
    },
    {
      name     = "private_subnet_3"
      new_bits = 4
    },
    {
      name     = "public_subnet_1"
      new_bits = 4
    },
    {
      name     = "public_subnet_2"
      new_bits = 4
    },
    {
      name     = "public_subnet_3"
      new_bits = 4
    },
  ]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.4.0"

  name = var.name
  cidr = var.vpc_cidr_range

  azs             = data.aws_availability_zones.azs.names
  private_subnets = local.private_cidr_ranges
  public_subnets  = local.public_cidr_ranges

  enable_nat_gateway = true
  enable_dns_hostnames = true
  enable_vpn_gateway = false

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-vpc",
    },
  )
}