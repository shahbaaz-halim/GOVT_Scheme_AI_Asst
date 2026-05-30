terraform {
  backend "s3" {
    bucket       = "shah-ai-tf-state-bucket"
    key          = "govt_scheme_ai_asst/terraform.tfstate" 
    region       = "ap-south-2"                           
    encrypt      = true
    use_lockfile = true                                  # Native S3 state locking (No DynamoDB table required!)
  }
}