provider "aws" {
  allowed_account_ids = "${var.account_ids}"
  region              = "${var.aws_region}"
}

terraform {
  backend "s3" {
    bucket  = "martian-prod-tfstate-gbc"
    key     = "terraform.tfstate"
    encrypt = "true"
  }
}

module "BaseNetwork" {
	source = "./base-network"
	
}