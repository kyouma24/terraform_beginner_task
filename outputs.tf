output "instance_id" {
  value       = aws_instance.my_instance.id
}

output "private_ip" {
  value       = aws_instance.my_instance.private_ip
}

output "public_ip" {
  value       = aws_instance.my_instance.public_ip
}

output "key_pair" {
  value       = aws_key_pair.tfkey.key_name
}

output "vpc_id" {
  value       = aws_vpc.testvpc.id
}

output "subnet_id" {
  value       = aws_subnet.test-subnet.id
}

output "security_group" {
  value       = aws_security_group.test_sg.id
}

output "route_table" {
  value       = aws_route_table.testroute-table.id
}

output "internet_gw" {
  value       = aws_internet_gateway.gw.tags.Name
}

output "eip" {
    value = aws_eip.my_eip.public_ip
}

output "ebs_volume_name" {
    value = aws_ebs_volume.tf_ebs.tags.Name
}

output "kms_alias" {
    value = aws_kms_alias.a.name
}