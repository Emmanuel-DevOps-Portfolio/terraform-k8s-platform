terraform {
  backend "s3" {
    bucket         = "emmanuel-terraform-state-eu-west-1"
    key            = "k8s-platform/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}