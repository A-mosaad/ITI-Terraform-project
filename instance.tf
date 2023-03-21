module "web" {
    source = "/instance"
    instance-name = ["web1","web3"]
    instance-name2 = ["web2","web4"]
    instance-type = "t2.micro"
    sg-name = "Allow_http_ssh"
    sg2-name = "Allow http"
    sg-description = "Allow_http_ssh"
    ingress_rules = [
      { description = "allow_http", from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], ipv6_cidr_blocks = ["::/0"] },
      { description = "allow_ssh", from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], ipv6_cidr_blocks = ["::/0"] }
    ]
    egress_rules = [
      { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"], ipv6_cidr_blocks = ["::/0"] }
    ]
    ingress_rule_lb = [
      { description = "allow_http", from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], ipv6_cidr_blocks = ["::/0"] }
    ]
    egress_rule_lb = [
      { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], ipv6_cidr_blocks = ["::/0"] }
    ]
    sg-lb-name = "Allow_http_lb"
    sg-lb-description = "Allow_http_lb"
    lb-name = "network-lb"
    lb2-name = "inlb"
    lb-type = "network"
    ports = {
      http = 80
    }
}
