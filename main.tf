terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  region = "eu-central-1"
}

locals {
  general_tags = {
    project     = "Academy-DevOps"
    environment = "Education"
    Name        = "lab1"
  }
}

module "vpc" {
  source = "./modules/vpc"
  tags   = local.general_tags
}