resource "aws_efs_file_system" "shared_store" {
  creation_token = "${var.prefix}-shared_store"
  encrypted = true

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
	Name = "${var.prefix}-shared_store"
  }
}

resource "aws_security_group" "shared_store" {
  name        = "shared_store"
  vpc_id      = "${aws_vpc.amber.id}"

  # SSH access from anywhere
  ingress {
	from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.amber-vms.cidr_block]
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
	Name = "shared_store"
  }
}

resource "aws_efs_mount_target" "shared_store" {
  file_system_id = aws_efs_file_system.shared_store.id
  subnet_id      = aws_subnet.amber-vms.id
  security_groups = [aws_security_group.shared_store.id]
}
