variable "ami" {
  type = map

  default = {
    "us-east-1" = "ami-04169656fea786776"
    
      }
}
variable "instance_count" {
   default = "1"
  
}
variable "instances_tags" {
  #default = "Sample"
  type    = string

}
variable "instance_type" {
  default = "t2.nano"
}

variable "aws_region" {
  default = "us-east-1"
}
