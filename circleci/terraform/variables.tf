variable "circleci_org" {
    description = "The Circle CI organization."
}

variable "circleci_project" {
    description = "The Circle CI project."
    default     = "parity-node"
}

variable "circleci_token" {
   description = "The Circle CI token."
}

variable "aws_access_key" {}
variable "aws_secret_access_key" {}

variable "public_key" {
    description = "The public SSH key to access the AWS EC2 instance."
    default = ""
}