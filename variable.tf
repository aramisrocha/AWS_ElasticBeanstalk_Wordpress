variable "region" {
  default = "us-east-2"
}



variable "network_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_count" {
  type    = number
  default = 2
}