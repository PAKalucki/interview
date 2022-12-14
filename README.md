# Requirements

## Terraform  
You will be using Terraform to provision the following two resources:
1. An AWS S3 Bucket
2. An AWS EC2 Instance
a. Make sure it’s the `t3.micro` tier so you aren’t charged.
b. Make sure it uses the `Amazon Linux 2 OS`

There are a few things to consider when provisioning these resources. First, you will need to be able
read files and write files from your S3 bucket. That means you’ll need to create an IAM policy that
allows for read/write access and attach it to the EC2 instance. Additionally, you’ll be connecting to
your EC2 instance using SSH, so you’ll need to do the following:
1. Create an AWS Key Pair resource (this doesn’t need to be done with terraform).
2. Attach it to the EC2 instance (this can be done with terraform).
3. Create a Security Group with Port 22 & 443 Access.
4. Attach the Security Group to the EC2 instance.


## Ansible
You will be using ansible to do the following:
1. Connect to your EC2 Instance using SSH.
2. Ensure Python3 is installed on the EC2 instance.
3. Install the boto3 library using pip3.
4. Create the following two directories:
a. downloads
b. processed
5. Copy the python script that will process your S3 files (this will be covered below).
6. Create a cronjob that will run every minute to check for and process your S3 files.

## Python

In this portion of the exercise, you’ll be writing a python script that will be handling and processing
the files in your S3 bucket. There are three main portions of the script:
1. The “get” operation.
2. The “process” operation.
3. The “put” operation.
4. Handling “errors”.
Make sure you organize your S3 bucket in a logical fashion. For example, one folder in your bucket will
handle the “input” files. Another folder will contain the processed files, also called the “output” files.
Finally, you should have another folder that will hold the files that couldn’t be processed. This folder
should be called “errors”.
The first portion of the script will handle the `get operation`. We want the script to pull the file from
the bucket folder labeled `input` and save it to the local folder `downloads`. Make sure you create
that folder using ansible in the previous section.
The second portion of the script will handle the `put operation`. After you’ve “processed” the file
you will push it back to the S3 bucket in the folder called `output`.
The final portion of the script will handle any errors that may arise during the execution of the code. If
the file fails to be parsed, then you will push that file to the S3 bucket folder labeled `error`.

=================================================================================================================

# Solution
- Folder terraform contains terraform files that create EC2 instace, S3 bucket and it's dependencies like VPC etc.
- Folder terraform/templates contains template for hosts file and script.py which are templated by Terraform to be used by Ansible
- Folder terraform/ansible contains Ansible playbook that installs boto3, creates directories, copies pyhon scrip to ec2 and creates cron job to run it every minute
- Folder terraform/files contains test files that will be processes by python script and that are uploaded to s3 by terraform
- Ansible is bootstrapped by Terraform in ansible.tf

# Comments
- I've made EC2 instance with public ip and SG limited to my outbound home ip. In production scenario I would be using ssh tunneling over ssm.  
- Requirements don't specify clearly what "processing" should be done by python script so I made it update json file
- Requirements don't specify that file from input in s3 should be removed after processing which seems like something that should be done in real life scenario to avoid processing the same file over and over  