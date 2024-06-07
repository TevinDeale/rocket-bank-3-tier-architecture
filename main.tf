terraform {
  cloud {
    organization = "RocketBank"

    workspaces {
      name = "rocket-bank-3-tier-aws"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./modules/vpc"

  #VPC
  vpc_cidr     = var.vpc_cidr
  enable_ipv6  = var.enable_ipv6
  vpc_tag_name = var.vpc_tag_name

  #Subnet
  subnets = var.subnets
  subnet_ipv6_cidr = cidrsubnets(
    module.vpc.vpc_ipv6_cidr,
    8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8
  )

  #IGW
  igw_name = var.igw_name

  #EOIGW
  eigw_name = var.eigw_name

  #Route Tables
  public_rt_name  = var.public_rt_name
  private_rt_name = var.private_rt_name

  #Route Table Associations
  public_subnet_names  = var.public_subnet_names
  private_subnet_names = var.private_subnet_names
}

module "sg" {
  source = "./modules/sg"

  #SG
  security_groups = var.security_groups
  vpc_id          = module.vpc.vpc_id

  #SG EGRESS RULES
  sg_ingress_rule = var.sg_ingress_rule
  sg_egress_rule  = var.sg_egress_rule
}

locals {
  sg_name_to_id     = { for sg in module.sg.security_groups : sg.name => sg.id }
  subnet_name_to_id = { for subnet in module.vpc.subnets : subnet.name => subnet.ID }
}

module "instance" {
  source = "./modules/ec2"

  instances = [
    #SAS-INSTANCE
    {
      ami            = "ami-00beae93a2d981137"
      type           = "t2.micro"
      name           = "rb-sas-use-1a"
      subnet_id      = lookup(local.subnet_name_to_id, "rocket-bank-use-1a-sas")
      public_ipv4    = false
      ipv6_count     = 1
      security_group = [lookup(local.sg_name_to_id, "sas-sg")]
      key            = "rb"
      volume_size    = 20
      user_data      = templatefile("${path.module}/userdata/tailscale.sh", { tailscale_key = var.tailscale_key })
    },
    #web Instances
    {
      ami            = "ami-00beae93a2d981137"
      type           = "t2.micro"
      name           = "rb-web-use-1a"
      subnet_id      = lookup(local.subnet_name_to_id, "rocket-bank-use-1a-web")
      public_ipv4    = false
      ipv6_count     = 1
      security_group = [lookup(local.sg_name_to_id, "web-sg")]
      key            = "rb"
      volume_size    = 8
      user_data      = templatefile("${path.module}/userdata/hostname.sh", { name = "rb-web-use-1a" })
    },
    {
      ami            = "ami-00beae93a2d981137"
      type           = "t2.micro"
      name           = "rb-web-use-1b"
      subnet_id      = lookup(local.subnet_name_to_id, "rocket-bank-use-1b-web")
      public_ipv4    = false
      ipv6_count     = 1
      security_group = [lookup(local.sg_name_to_id, "web-sg")]
      key            = "rb"
      volume_size    = 8
      user_data      = templatefile("${path.module}/userdata/hostname.sh", { name = "rb-web-use-1b" })
    },
    {
      ami            = "ami-00beae93a2d981137"
      type           = "t2.micro"
      name           = "rb-web-use-1c"
      subnet_id      = lookup(local.subnet_name_to_id, "rocket-bank-use-1c-web")
      public_ipv4    = false
      ipv6_count     = 1
      security_group = [lookup(local.sg_name_to_id, "web-sg")]
      key            = "rb"
      volume_size    = 8
      user_data      = templatefile("${path.module}/userdata/hostname.sh", { name = "rb-web-use-1c" })
    },
    #APP-INSTANCES
    {
      ami            = "ami-00beae93a2d981137"
      type           = "t2.micro"
      name           = "rb-app-use-1a"
      subnet_id      = lookup(local.subnet_name_to_id, "rocket-bank-use-1a-app")
      public_ipv4    = false
      ipv6_count     = 1
      security_group = [lookup(local.sg_name_to_id, "app-sg")]
      key            = "rb"
      volume_size    = 8
      user_data      = templatefile("${path.module}/userdata/hostname.sh", { name = "rb-app-use-1a" })
    },
    {
      ami            = "ami-00beae93a2d981137"
      type           = "t2.micro"
      name           = "rb-app-use-1b"
      subnet_id      = lookup(local.subnet_name_to_id, "rocket-bank-use-1b-app")
      public_ipv4    = false
      ipv6_count     = 1
      security_group = [lookup(local.sg_name_to_id, "app-sg")]
      key            = "rb"
      volume_size    = 8
      user_data      = templatefile("${path.module}/userdata/hostname.sh", { name = "rb-app-use-1b" })
    },
    {
      ami            = "ami-00beae93a2d981137"
      type           = "t2.micro"
      name           = "rb-app-use-1c"
      subnet_id      = lookup(local.subnet_name_to_id, "rocket-bank-use-1c-app")
      public_ipv4    = false
      ipv6_count     = 1
      security_group = [lookup(local.sg_name_to_id, "app-sg")]
      key            = "rb"
      volume_size    = 8
      user_data      = templatefile("${path.module}/userdata/hostname.sh", { name = "rb-app-use-1c" })
    },
    #DB-INSTANCES
    {
      ami            = "ami-00beae93a2d981137"
      type           = "t2.micro"
      name           = "rb-db-use-1a"
      subnet_id      = lookup(local.subnet_name_to_id, "rocket-bank-use-1a-db")
      public_ipv4    = false
      ipv6_count     = 1
      security_group = [lookup(local.sg_name_to_id, "db-sg")]
      key            = "rb"
      volume_size    = 8
      user_data      = templatefile("${path.module}/userdata/hostname.sh", { name = "rb-db-use-1a" })
    },
    {
      ami            = "ami-00beae93a2d981137"
      type           = "t2.micro"
      name           = "rb-db-use-1b"
      subnet_id      = lookup(local.subnet_name_to_id, "rocket-bank-use-1b-db")
      public_ipv4    = false
      ipv6_count     = 1
      security_group = [lookup(local.sg_name_to_id, "db-sg")]
      key            = "rb"
      volume_size    = 8
      user_data      = templatefile("${path.module}/userdata/hostname.sh", { name = "rb-db-use-1b" })
    },
    {
      ami            = "ami-00beae93a2d981137"
      type           = "t2.micro"
      name           = "rb-db-use-1c"
      subnet_id      = lookup(local.subnet_name_to_id, "rocket-bank-use-1c-db")
      public_ipv4    = false
      ipv6_count     = 1
      security_group = [lookup(local.sg_name_to_id, "db-sg")]
      key            = "rb"
      volume_size    = 8
      user_data      = templatefile("${path.module}/userdata/hostname.sh", { name = "rb-db-use-1c" })
    },
  ]
}
