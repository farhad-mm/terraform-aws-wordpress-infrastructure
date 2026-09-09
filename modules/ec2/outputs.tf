output "instance_id" {
  value = aws_instance.wordpress.id
}

output "availability_zone" {
  value = aws_instance.wordpress.availability_zone
}

output "public_ip" {
  value = aws_instance.wordpress.public_ip
}
