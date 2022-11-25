terraform {
  required_version = "= 1.3.5"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 4.41.0"
    }
  }
  
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "findprofessional"

    workspaces {
      name = "dev"
    }
  }
}
