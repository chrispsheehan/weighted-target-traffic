terraform {
  required_version = ">= 1.0.8"
  required_providers {
    aws = {
      version = "5.70.0"
      source  = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "chrispsheehan-weighted-target-traffic-tfstate"
    key            = "api-state/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "chrispsheehan-weighted-target-traffic-tf-lockid"
  }
}

provider "aws" {
  region = var.region
}
