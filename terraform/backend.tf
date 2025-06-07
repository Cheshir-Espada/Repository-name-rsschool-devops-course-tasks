terraform {
  backend "s3" {
    bucket         = "alex-tf-state-bucket"
    key            = "rsschool/devops-course/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
  }
}

