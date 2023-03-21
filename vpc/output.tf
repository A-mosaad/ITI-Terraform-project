utput "vpc_id" {
  value = aws_vpc.test.id
}
output "subnet_id" {
  value = aws_subnet.test-subnet[*].id
}
output "subnet_id2" {
  value = aws_subnet.test2-subnet[*].id
}
