# Define an S3 bucket that already exists in AWS
terraform {
    backend "s3" {
        bucket = "terra-state-dove-cablab-1234" # bucket name
        key = "terraform/backend" # the file where state will be stored
        region = "us-west-2"
    }
}