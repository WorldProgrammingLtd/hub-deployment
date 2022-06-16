variable "region" {
  description = "The AWS Region in which all resources should be created."
}

variable "prefix" {
  description = "Prefix for this setup instance to distiguish from other installs of the same thing"
}

variable "dns_zone" {
  description = "Zone in cloudflare for our DNS records"
}

variable "ssh_user_name" {
  description = "Username to use for SSH+sudo into VMs. Should match AMI's default, you probably don't want to fiddle unless selecting another AMI"
  default = "ec2-user"
}

variable "ssh_public_key" {
  description = "SSH Public key to insert into VMs for sudo access to them. Ensure you have the private key for ansible to use."
}

variable "worker_vm_count" {
  description = "Number of worker vms"
  default = 2
}

variable "hubvmsize" {
  description = "Hub VM type"
  default = "m5a.xlarge"
}

variable "workervmsize" {
  description = "Workbench VM type"
  default = "m5a.large"
}

variable "dbusername" {
  description = "DB username"
  default = "hubdb"
}

variable "dbpassword" {
  description = "DB password"
}

variable "setup_from_address_range" {
  description = "IP addresses to open for SSH, so ansible can talk to the VMs for step 2. In the form of 10.20.30.40/24"
}

variable "use_iam_for_s3" {
  description = "Use iam policy for s3 access"
  default = true
}

