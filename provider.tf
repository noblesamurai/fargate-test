# Specify the provider and access details
provider "aws" {
  version = "~> 2.58"
  shared_credentials_file = "$HOME/.aws/credentials"
  profile = var.profile
  region = var.region
}
