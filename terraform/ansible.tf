### template hosts file for ansible
data "template_file" "hosts" {
  template = "${file("${path.module}/templates/hosts.tftpl")}"
  vars = {
    ip_addr = aws_eip.ec2_eip.public_ip
  }
}

resource "null_resource" "hosts" {
  triggers = {
    template = "${data.template_file.hosts.rendered}"
  }
  provisioner "local-exec" {
    command = "echo \"${data.template_file.hosts.rendered}\" > ansible/hosts"
  }
}

### template script.py file for ansible
data "template_file" "script" {
  template = "${file("${path.module}/templates/script.py.tftpl")}"
  vars = {
    region = var.region
    bucket = module.s3_bucket.s3_bucket_id
  }
}

resource "null_resource" "script" {
  triggers = {
    template = "${data.template_file.script.rendered}"
  }
  provisioner "local-exec" {
    command = "echo \"${data.template_file.script.rendered}\" > ansible/script.py"
  }
}


### save ssh key for Ansible to use
### this is questionable from security point of view
resource "null_resource" "key" {
  provisioner "local-exec" {
    command = "echo \"${tls_private_key.this.private_key_pem}\" > ansible/key.pem"
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
     }
  }
}

### execute ansible playbook
resource "null_resource" "ansible" {
  triggers = {
    "script" = data.template_file.script.rendered
  }

  provisioner "local-exec" {
    command = "ansible-playbook -T 300 -i hosts --private-key key.pem playbook.yaml"
    working_dir = "ansible"
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
     }
  }

  depends_on = [
    null_resource.hosts,
    null_resource.script,
    null_resource.key,
    module.ec2_instance
  ]
}