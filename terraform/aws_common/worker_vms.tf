resource "aws_security_group" "worker" {
  name        = "${var.prefix}-worker"
  vpc_id      = "${aws_vpc.amber.id}"

  # SSH access for setup
  ingress {
	description = "SSH from host"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.setup_from_address_range}"]
  }

  ingress {
	description = "Nomad RPC"
    from_port   = 4647
    to_port     = 4647
    protocol    = "tcp"
	cidr_blocks = [aws_vpc.amber.cidr_block]
  }

  ingress {
	description = "Worker on demand"
    from_port   = 20000
    to_port     = 32000
    protocol    = "tcp"
	cidr_blocks = [aws_vpc.amber.cidr_block]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
	cidr_blocks = ["0.0.0.0/0"]
	ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
	Name = "${var.prefix}-worker"
  }
}

resource "aws_instance" "worker" {
  count = var.worker_vm_count
  connection {
    # The default username for our AMI
    user = "${var.ssh_user_name}"
  }
  instance_type = "${var.workervmsize}"

  # Lookup the correct AMI based on the region
  ami = "${data.aws_ami.centos.id}"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.common-auth.id}"

  # the size of the root ebs volume
  root_block_device {
    volume_size = 20
  }

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.worker.id}"]
  subnet_id = aws_subnet.amber-vms.id

  associate_public_ip_address = true
  tags = {
	Name = "${var.prefix}-worker-${count.index}"
 }
}
