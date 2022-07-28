resource "aws_instance" "dove-inst" {
  ami                    = var.AMIS[var.REGION] # accessing a Map type variable
  instance_type          = "t2.micro"
  availability_zone      = var.ZONE1                # accessing a normal variable
  key_name               = "dove-key"               # this is an existing key-pair in AWS
  vpc_security_group_ids = ["sg-0c17af7a2ebc53163"] # existing security group in AWS
  tags = {
    "Name"    = "Dove-Instance"
    "Project" = "Dove"
  }
}