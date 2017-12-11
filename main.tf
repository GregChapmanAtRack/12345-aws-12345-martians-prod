provider "aws" {
  allowed_account_ids = ["057866020917"]
  region              = "us-east-1"
}

terraform {
  backend "s3" {
    bucket  = "martian-prod-tfstate-gbc"
    key     = "terraform.tfstate"
    encrypt = "true"
  }
}

module "Base-Newtork-GBC" {
	source ="./base-network"
	environment="Martian Prod"
	name = "Prod-Martian-subnets-Ticket-1111"
	public_subnets = ["172.18.0.0/22", "172.18.4.0/22"]
	private_subnets = ["172.18.32.0/21", "172.18.40.0/21"]
}