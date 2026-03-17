terraform {
  required_version = ">= 1.0.0" # Ensure that the Terraform version is 1.0.0 or higher

  required_providers {
    aws = {
      source  = "hashicorp/aws" # Specify the source of the AWS provider
      version = "~> 4.0"        # Use a version of the AWS provider that is compatible with version
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

module "vpc" {
  source = "../modules/vpc"
}

module "subnet" {
  source = "../modules/subnet"
  vpc_id = module.vpc.vpc_id
}

module "routing" {
  source    = "../modules/routing"
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.subnet.subnet_id.public
}

module "security_group" {
  source = "../modules/security_group"
  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source            = "../modules/ec2"
  subnet_id         = module.subnet.subnet_id.public
  security_group_id = module.security_group.sg_id
}
