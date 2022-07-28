provider "aws" {
  region = "us-west-2"
  # access_key = "test123" # don't do this, use AWSCLI with proper config
  # secret_key = "test456" # don't do this, use AWSCLI with proper config
}

# defining resource of type "aws_instance", giving it name "intro"
# the name "intro" is a terraform resource reference name, not the name of the AWS resource
resource "aws_instance" "intro" {
  ami                    = "ami-098e42ae54c764c35"
  instance_type          = "t2.micro"
  availability_zone      = "us-west-2a"
  key_name               = "dove-key"               # this is an existing key-pair in AWS
  vpc_security_group_ids = ["sg-0c17af7a2ebc53163"] # existing security group in AWS
  tags = {
    "Name"    = "Dove-Instance"
    "Project" = "Dove"
  }
}