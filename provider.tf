terraform {
  required_version = "= 1.5.7"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 4.67.0"
    }
  }
  
  cloud {
    organization = "findprofessional"

    workspaces {
      name = "dev"
    }
  }
}
