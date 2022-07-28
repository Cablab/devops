# Normal variable declaration
variable "REGION" {
  default = "us-west-2"
}

variable "ZONE1" {
  default = "us-west-2a"
}

# Map variable declaration
variable "AMIS" {
  type = map(any)
  default = {
    us-west-2 = "ami-098e42ae54c764c35"
    us-west-1 = "ami-0d9858aa3c6322f73"
  }
}