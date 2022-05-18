output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.my-instance.0.id
}

output "private_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.my-instance.0.private_ip
}