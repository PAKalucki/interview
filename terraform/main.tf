terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.46.0"
    }
  }

  ### remove this if you want to run it
  cloud {
    organization = "pakalucki"

    workspaces {
      name = "interview_task"
    }
  }
  ###
}

provider "aws" {
  region  = var.region

  default_tags {
    tags = {
      Created_by = "przemyslaw.k@infogen-labs.com"
    }
  }
}