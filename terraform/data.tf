### latest amazon linux 2 AMI
data "aws_ami" "amzn2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

### my public ip to be whitelisted in SG for EC2 access
data "http" "my_public_ip" {
  url = "http://ipv4.icanhazip.com"
}
