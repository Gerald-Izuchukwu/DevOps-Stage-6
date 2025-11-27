terraform {
  backend "s3" {
    bucket         = "devops-stage6-terraform-state-8bb03bd2"
    key            = "todo-app/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "devops-stage6-terraform-locks"
  }
}