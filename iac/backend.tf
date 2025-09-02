terraform {
  backend "s3" {
    bucket                      = "asgard-tf"
    key                         = "terraform/state.tfstate"
    region                      = "us-east-1"
    endpoint                    = "https://s3.us-west-002.backblazeb2.com"
    profile                     = "backblaze"
    skip_requesting_account_id  = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}
