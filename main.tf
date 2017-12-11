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

# Do not rename a module after creating else the entire resource will be rebuilt
# Original work might be destroyed
module "Base-Newtork-GBC" {
	source ="./base-network"
	environment="Martian Prod"
	name = "Prod-Martian-subnets-Ticket-1111"
	public_subnets = ["172.18.0.0/22", "172.18.4.0/22"]
	private_subnets = ["172.18.32.0/21", "172.18.40.0/21"]
}
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
resource "aws_security_group" "Inbound-Web" {
	name = "Allow HTTP"
	description = "Allow all port 80 TCP requests"
	vpc_id = "${module.Base-Newtork-GBC.vpc_id}"
	ingress { 
		from_port = 80 
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		}
}

resource "aws_instance" "First-EC2-server-public" {
	ami = "${data.aws_ami.ubuntu.id}"
	instance_type = "t2.micro"
	tags = { Name = "First-Instance-${count.index}" }
	#subnet_id = "${module.Base-Newtork-GBC.public_subnets[0]}"
	associate_public_ip_address = 1
	vpc_security_group_ids = ["${aws_security_group.Inbound-Web.id}"]
	user_data = "${file("./bootstrap.sh")}"
	provisioner "local-exec" {
	command="echo ${self.public_ip} > file.txt"
	}
	count = 4
	#To iterate through the array, use the 'element' method to assure starts across all subnets
	subnet_id= "${element( module.Base-Newtork-GBC.public_subnets, count.index)}"
}



