# Create AWS Key Pair
resource "aws_key_pair" "dove-key" {
  key_name   = "dovekey"
  public_key = file("dovekey.pub") # reading ./dovekey.pub file
}

resource "aws_instance" "dove-instance" {
  ami               = var.AMIS[var.REGION]
  instance_type     = "t2.micro"
  availability_zone = var.ZONE1

  # You can reference Terraform resources you've previously created
  # by calling <terraform-resource-type>.<given-resource-name>, and then
  # access fields from it with .<field-name>
  key_name = aws_key_pair.dove-key.key_name # Key Pair terraform resource defined above

  vpc_security_group_ids = ["sg-0c17af7a2ebc53163"] # existing security group in AWS
  tags = {
    "Name"    = "Dove-Instance"
    "Project" = "Dove"
  }

  # Use a Terraform "file" Provisioner to upload a specified local file
  # to the remote resource once it has been created
  provisioner "file" {
    source      = "web.sh"
    destination = "/tmp/web.sh"
  }

  # Once the local file has been copied to the remote resource, you can use a
  # "remote-exec" Provisioner to get onto the host and run commands (like
  # executing the script)
  provisioner "remote-exec" {
    # inline is a list of shell commands to run
    inline = [
      "chmod u+x /tmp/web.sh",
      "sudo /tmp/web.sh"
    ]
  }

  # In order for Terraform to connect to the remote resource to copy the local file,
  # you need to pass credentials so it can get onto the resource. You do that with
  # a Terraform "connection"
  connection {
    user        = var.USER
    private_key = file("dovekey")
    host        = self.public_ip # In Terraform, there are fields you can reference off of "self"
  }
}