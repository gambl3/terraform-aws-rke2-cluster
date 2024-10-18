terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = "~> 1.0"
}

provider "aws" {
  region     = var.region

  default_tags {
    tags = {
      "KeepRunning"                    = "true"
      "provisioner"                    = "terraform"
      "kubernetes.io/cluster/aws-rke2" = "shared"
    }
  }
}
