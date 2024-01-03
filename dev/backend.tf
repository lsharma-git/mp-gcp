terraform {

  backend "gcs" {
    bucket = "terraform_private_tfstate_files"
    prefix = "terraform/state"
  }

}
