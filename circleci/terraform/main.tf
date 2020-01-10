provider "aws" {
  region = "us-west-2"
}

provider "circleci" {
  api_token    = var.circleci_token
  vcs_type     = "github"
  organization = var.circleci_org
}

resource "circleci_environment_variable" "aws_access_key" {
  project = var.circleci_project
  name    = "AWS_ACCESS_KEY_ID"
  value   = var.aws_access_key
}

resource "circleci_environment_variable" "aws_secret_access_key" {
  project = var.circleci_project
  name    = "AWS_SECRET_ACCESS_KEY"
  value   = var.aws_secret_access_key
}

resource "circleci_environment_variable" "public_key" {
  project = var.circleci_project
  name    = "TF_VAR_PUBLIC_KEY"
  value   = var.public_key
}