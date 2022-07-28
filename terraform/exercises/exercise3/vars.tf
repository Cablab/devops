variable "REGION" {
  default = "us-west-2"
}

variable "ZONE1" {
  default = "us-west-2a"
}

variable "AMIS" {
  type = map(any)
  default = {
    us-west-2 = "ami-098e42ae54c764c35"
    us-west-1 = "ami-0d9858aa3c6322f73"
  }
}

variable "USER" {
  default = "ec2-user"
}