resource "tls_private_key" "this" {
  algorithm = "RSA"
}

module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "2.0.1"

  key_name   = "${var.prefix}-key-${var.region}"
  public_key = trimspace(tls_private_key.this.public_key_openssh)
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.2.1"

  name = "${var.prefix}-ec2-${var.region}"

  ami                    = data.aws_ami.amzn2.id
  instance_type          = "t3.micro"
  key_name               = module.key_pair.key_pair_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id              = module.vpc.public_subnets[0]

  create_iam_instance_profile = true

  iam_role_policies = {
    AmazonSSMPatchAssociation    = "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation"
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    S3AccessPolicy = aws_iam_policy.policy.arn
  }

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 8
    },
  ]

  user_data = <<-EOT
  #!/bin/bash
  sudo yum install -y python3
  EOT


  tags = {
    Name = "${var.prefix}-instance-${var.region}"
  }
}

resource "aws_security_group" "ec2_sg" {
  vpc_id = module.vpc.vpc_id

  egress {
    description = "Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Inbound https allowed"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.my_public_ip]
  }

  ingress {
    description = "Inbound ssh allowed"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_public_ip]
  }
}

resource "aws_iam_policy" "policy" {
  policy = data.aws_iam_policy_document.policy.json
  description = "IAM Policy granting access to s3"
  name   = "${var.prefix}-policy-${var.region}"
}

data "aws_iam_policy_document" "policy" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:DeleteObject",
    ]
    effect = "Allow"
    resources = [
      module.s3_bucket.s3_bucket_arn,
      "${module.s3_bucket.s3_bucket_arn}/*",
    ]
  }
}

resource "aws_eip" "ec2_eip" {
  ### elastic ip for static public IP
  vpc = true

  instance                  = module.ec2_instance.id
  associate_with_private_ip = module.ec2_instance.private_ip
}