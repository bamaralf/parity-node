terraform {
  backend "s3" {
    bucket = "radar-relay-parity-infra-tfstate"
    key    = "infra.tfstate"
    region = "us-west-2"
  }
}