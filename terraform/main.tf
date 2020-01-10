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
  public_key = var.public_key
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
      volume_size = 500
      encrypted   = true
      kms_key_id  = aws_kms_key.this.arn
    }
  ]

#   tags = {
#     "Env"      = "Dev"
#   }
}

