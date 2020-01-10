terraform {
  backend "s3" {
    bucket = "radar-relay-parity-infra-tfstate"
    key    = "circleci.tfstate"
    region = "us-west-2"
  }
}