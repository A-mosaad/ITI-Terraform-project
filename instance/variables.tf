variable "instance-name" {
    type = list(string)
}
variable "instance-name2" {
    type = list(string)
}


variable "instance-type" {
    type = string
}
variable "sg-name" {
    type = string

}

variable "sg2-name" {
    type = string

}

variable "sg-description" {
    type = string
}
variable "ingress_rules" {
    type = list(object({
        description = string
        from_port = number
        to_port = number
        protocol = string
        cidr_blocks = list(string)
        ipv6_cidr_blocks = list(string)
    }))
}
variable "egress_rules" {
    type = list(object({
        from_port = number
        to_port = number
        protocol = string
        cidr_blocks = list(string)
        ipv6_cidr_blocks = list(string)
    }))
}

variable "lb-name" {
    type = string
}
variable "lb-type" {
    type = string
}

variable "sg-lb-name" {
    type = string
}
variable "sg-lb-description" {
    type = string
}


variable "ingress_rule_lb" {
    type = list(object({
        description = string
        from_port = number
        to_port = number
        protocol = string
        cidr_blocks = list(string)
        ipv6_cidr_blocks = list(string)
    }))
}

variable "egress_rule_lb" {
    type = list(object({
        from_port = number
        to_port = number
        protocol = string
        cidr_blocks = list(string)
        ipv6_cidr_blocks = list(string)
    }))
}

variable "ports" {
    type = map(number)

}

variable "lb2-name" {
    type = string
}
