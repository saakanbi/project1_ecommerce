output "jenkins_public_ip" {
  description = "Public IP of Jenkins EC2 instance"
  value       = aws_instance.jenkins_server.public_ip
}

output "app_server_public_ip" {
  description = "Public IP of App EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "jenkins_url" {
  description = "Access Jenkins via this URL"
  value       = "http://${aws_instance.jenkins_server.public_ip}:8081"
}

output "app_url" {
  description = "Access Application via this URL"
  value       = "http://${aws_instance.app_server.public_ip}:8080"
}
