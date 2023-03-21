data "aws_ami" "ubuntu" {
  most_recent      = true
  owners           = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

module "test" {
  source = "/vpc"
  cidr = "10.0.0.0/16"
  vpc-name = "test-vpc"
  subnet_cidr_block = ["10.0.4.0/24","10.0.5.0/24"]
  subnet_cidr_block2 = ["10.0.6.0/24","10.0.7.0/24"]
  subnet_name = ["public-3","public-4"]
  subnet_name2 = ["private-3","private-4"]
  az = ["us-east-1a","us-east-1c"]
  az2 = ["us-east-1b","us-east-1e"]
  igw-name = "igw"
  route-gw = "0.0.0.0/0"
  igw-route-name = "example"
  nat-route-name = "nat-route"
  nat-gw-name = "nat-gw"
}

resource "aws_security_group" "sg" {
  name        = var.sg-name
  description = var.sg-description
  vpc_id      = module.test.vpc_id
  dynamic "ingress" {
    for_each = var.ingress_rules
    iterator = item   #optional
    content {
        description = item.value.description
        from_port = item.value.from_port
        to_port = item.value.to_port
        protocol = item.value.protocol
        cidr_blocks = item.value.cidr_blocks
        ipv6_cidr_blocks = item.value.ipv6_cidr_blocks
    }
  }
  dynamic "egress" {
    for_each = var.egress_rules
    iterator = item   #optional
    content {
        from_port = item.value.from_port
        to_port = item.value.to_port
        protocol = item.value.protocol
        cidr_blocks = item.value.cidr_blocks
        ipv6_cidr_blocks = item.value.ipv6_cidr_blocks
    }

  }

  tags = {
    Name = var.sg-name
  }
}

resource "aws_instance" "web" {
  ami = data.aws_ami.ubuntu.image_id
  count = 2
  instance_type = var.instance-type
  key_name = "iti"
  subnet_id = module.test.subnet_id[count.index]
  security_groups = [aws_security_group.sg.id]
  provisioner "local-exec" {
     command = "echo ${self.public_ip} >> inventory"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install httpd -y",
      "sudo systemctl enable --now httpd"
    ]
  }
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("/root/iti.pem")
    host        = self.public_ip
    timeout     = "4m"
  }

    Name = var.instance-name[count.index]
  }

    volume_tags = {
      Name = var.instance-name[count.index]
  }

resource "aws_instance" "web2" {
  ami = data.aws_ami.ubuntu.image_id
  count = 2
  instance_type = var.instance-type
  key_name = "iti"
  subnet_id = module.test.subnet_id2[count.index]
  security_groups = [aws_security_group.sg.id]
  tags = {
    Name = var.instance-name2[count.index]
  }

  volume_tags = {
    Name = var.instance-name2[count.index]
  }
}
resource "aws_security_group" "sg-lb" {
  name        = var.sg2-name
  description = var.sg-description
  vpc_id      = module.test.vpc_id
  dynamic "ingress" {
    for_each = var.ingress_rule_lb
    iterator = item   #optional
    content {
        description = item.value.description
        from_port = item.value.from_port
        to_port = item.value.to_port
        protocol = item.value.protocol
        cidr_blocks = item.value.cidr_blocks
        ipv6_cidr_blocks = item.value.ipv6_cidr_blocks
    }
  }
  dynamic "egress" {
    for_each = var.egress_rule_lb
    iterator = item   #optional
    content {
        from_port = item.value.from_port
        to_port = item.value.to_port
        protocol = item.value.protocol
         cidr_blocks = item.value.cidr_blocks
        ipv6_cidr_blocks = item.value.ipv6_cidr_blocks
    }
  }

}

resource "aws_lb_target_group" "test" {
  name     = "lb-tg2"
  for_each = var.ports
  port     = each.value
  protocol = "TCP"
  vpc_id   = module.test.vpc_id

  depends_on = [
    aws_lb.example
  ]

}

resource "aws_lb_target_group_attachment" "test" {
  for_each         = var.ports
  target_group_arn = aws_lb_target_group.test[each.key].arn
  target_id        = aws_instance.web[0].id
  port             = each.value
}

resource "aws_lb_target_group_attachment" "test-2" {
  for_each         = var.ports
  target_group_arn = aws_lb_target_group.test[each.key].arn
  target_id        = aws_instance.web[1].id
  port             = each.value
}

resource "aws_lb" "example" {
  name               = var.lb-name
  load_balancer_type = var.lb-type
  internal = false
  subnets            = [module.test.subnet_id[0], module.test.subnet_id[1]]
}

resource "aws_lb_listener" "front_end" {
  for_each = var.ports
  load_balancer_arn = aws_lb.example.arn
  port              = each.value
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test[each.key].arn
  }
}


resource "aws_lb_target_group" "test-tg" {
  name     = "lb-tg3"
  for_each = var.ports
  port     = each.value
  protocol = "TCP"
  vpc_id   = module.test.vpc_id

  depends_on = [
    aws_lb.example-2
  ]
}

resource "aws_lb_target_group_attachment" "test-1" {
  for_each         = var.ports
  target_group_arn = aws_lb_target_group.test-tg[each.key].arn
  target_id        = aws_instance.web2[0].id
  port             = each.value
}

resource "aws_lb_target_group_attachment" "test-3" {
  for_each         = var.ports
  target_group_arn = aws_lb_target_group.test-tg[each.key].arn
  target_id        = aws_instance.web2[1].id
  port             = each.value
}

resource "aws_lb" "example-2" {
  name               = var.lb2-name
  load_balancer_type = var.lb-type
  internal = true
  subnets            = [module.test.subnet_id2[0], module.test.subnet_id2[1]]
}

resource "aws_lb_listener" "front_end2" {
  for_each = var.ports
  load_balancer_arn = aws_lb.example-2.arn
  port              = each.value
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test-tg[each.key].arn
  }
}




