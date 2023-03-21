variable "cidr" {


}
variable "subnet_cidr_block" {
    type = list
}
variable "subnet_name" {
    type = list
}
variable "vpc-name" {
    type = string
}
variable "igw-name" {
    type = string
}
variable "route-gw" {
    type = string
}
variable "igw-route-name" {
    type = string
}
variable "az" {
    type = list
}

variable "az2" {
    type = list
}
variable "subnet_cidr_block2" {
    type = list
}
variable "subnet_name2" {
    type = list
}

variable "nat-gw-name" {
    type = string
}
variable "nat-route-name" {
    type = string
}

