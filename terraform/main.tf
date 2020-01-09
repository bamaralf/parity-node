provider "aws" {
  region = "us-west-2"
}

##################################################################
# Data sources to get VPC, subnet, security group and AMI details
##################################################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_ami" "parity_ami" {
#  executable_users = ["self"]
  most_recent      = true
  name_regex       = "^parity-node*"
  owners           = ["self"]

  filter {
    name   = "name"
    values = ["parity-node*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "parity-nodes-sg"
  description = "Security group for default usage with Parity EC2 nodes"
  vpc_id      = data.aws_vpc.default.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8545
      to_port     = 8546
      protocol    = "tcp"
      description = "Parity APIs ports"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH Access"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_rules        = ["all-all"]
}

resource "aws_eip" "this" {
  vpc      = true
  instance = module.ec2.id[0]
}

#resource "aws_placement_group" "parity_nodes" {
#  name     = "parity"
#  strategy = "cluster"
#}

resource "aws_key_pair" "ec2_key" {
  key_name   = "parity-ec2-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCkKx8xfW//qwcoAeXsVkL2ANiRGcddSQrTBSMBgcALlmC5ixXdDdi2NcoLQlEkuoldmOokoJKWjxXMZt9WWOshbpy+3gzS3cEqGWGPZQN+meh/sw7/OPh3WEvum7ZXZNZ1FF08ed88lidtTQjmGTAs9OQUKBHqt1BPM+UV5ZcGVUtuflshZ8fBh/q6I5rIge+SEU7jYlbC9851EcIvrON8UH92aRaE24OcdshmhOTzsJH6Vogla1mGVszQJTrSzRraXWLbDh6n30wNZHsaOjrk+mv6Hhmipuxw8DyzzfFKT7g2hSSO1tj3hhvX6zhLL3ACIWYCfvzXuXIaQr1nQRr586V6V5aaVyhX3wYc4wprANUyy2P6m1u7to9x5F+IQEm/Al0SOUTx6/rDtdSBgdDAOvd4AvNP02TiHzIxVwq/lEH2+yzQhUcx7lTYAtiw/z8Q9Nsq4t4xW8ieGVn8CPykS7pl7pdfRbRVLp1pcppJE65P9cHhnAKIz9BEu2T/un8Nfpdk09eFcay2vDKv8B7WKgwV4SR6QZDDK5ygq35uAG7UlEtZjD0Bz3l6ClPVD0u7sIgkvnFZJHXNxr6Hp9h6YESzxXfBhoL4okiuO0lSG1KdCAM5sriD9gTTQsTrSeFXYHj3nCtuwoNc2LXHI8tcYcJ8ikdRIzZxVwW9LbPNSQ== bamaral@local-pc"
}

resource "aws_kms_key" "this" {
}

module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.12.0"

  instance_count = 1

  name          = "parity_node"
  ami           = data.aws_ami.parity_ami.id
  instance_type = "t2.micro"
  subnet_id     = tolist(data.aws_subnet_ids.all.ids)[0]
  //  private_ips                 = ["172.31.32.5", "172.31.46.20"]
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  associate_public_ip_address = true
#  placement_group             = aws_placement_group.parity_nodes.id
  key_name                    = aws_key_pair.ec2_key.key_name
  user_data                   = templatefile("${path.module}/files/mount_ebs.tmpl",{drive_letter = var.drive_letter})

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 10
    },
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sd${var.drive_letter}"
      volume_type = "gp2"
      volume_size = 10
      encrypted   = true
      kms_key_id  = aws_kms_key.this.arn
    }
  ]

#   tags = {
#     "Env"      = "Dev"
#   }
}

