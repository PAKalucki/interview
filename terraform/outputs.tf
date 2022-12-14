output "private_key_openssh" {
  value = tls_private_key.this.private_key_openssh
  sensitive = true
  description = "Private key used to connect to EC2 in openssh format"
}

output "private_key_pem" {
  value = tls_private_key.this.private_key_pem
  sensitive = true
  description = "Private key used to connect to EC2 in PEM format"
}

output "public_ip" {
  value = aws_eip.ec2_eip.public_ip
  description = "Static public IP assigned to the instance"
}