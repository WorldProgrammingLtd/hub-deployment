resource "aws_security_group" "hub" {
  name        = "${var.prefix}-hub"
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
	description = "Ingress HTTP"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.amber.cidr_block]
  }

  ingress {
	description = "Ingress internal"
    from_port   = 9091
    to_port     = 9091
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.amber.cidr_block]
  }

  ingress {
	description = "Worker CA service registration"
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.amber.cidr_block]
  }

  ingress {
	description = "Test LDAP"
    from_port   = 3268
    to_port     = 3268
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.amber.cidr_block]
  }

  # outbound internet access
  egress {
	description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
	cidr_blocks = ["0.0.0.0/0"]
	ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
	Name = "${var.prefix}-hub"
  }
}

resource "aws_instance" "hub" {
  connection {
    # The default username for our AMI
    user = "${var.ssh_user_name}"
  }
  instance_type = "${var.hubvmsize}"
  iam_instance_profile = var.use_iam_for_s3 == true ? "${aws_iam_instance_profile.s3_instance_profile[0].name}" : null

  # Lookup the correct AMI based on the region
  ami = "${data.aws_ami.centos.id}"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.common-auth.id}"

  # the size of the root ebs volume
  root_block_device {
    volume_size = 20
  }

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.hub.id}"]
  subnet_id   = aws_subnet.amber-vms.id
  associate_public_ip_address = true
  tags = {
	Name = "${var.prefix}-hub"
  }
}

resource "aws_security_group" "hublb" {
  name        = "${var.prefix}-hublb"
  vpc_id      = "${aws_vpc.amber.id}"

  # SSH access from anywhere
  ingress {
	description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
	description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
	cidr_blocks = ["0.0.0.0/0"]
	ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
	Name = "${var.prefix}-hublb"
  }
}

resource "aws_lb" "hublb" {
  name = "${var.prefix}-hub-alb"

  load_balancer_type = "application"

  internal           = false
  subnets            = ["${aws_subnet.amber-lb.id}","${aws_subnet.amber-vms.id}"]
  security_groups    = [aws_security_group.hublb.id]
  tags = {
	Name = "${var.prefix}-hub"
  }
#  security_groups    = ["sg-edcd9784", "sg-edcd9785"]
}

resource "aws_lb_target_group" "hublb" {
  name             = "${var.prefix}-hublb"
  protocol         = "HTTP"
  target_type      = "instance"
  port             = 9090
  vpc_id           =  "${aws_vpc.amber.id}"
  tags = {
	Name = "${var.prefix}-hub"
  }
}

resource "aws_lb_target_group_attachment" "hub" {
  target_group_arn = aws_lb_target_group.hublb.arn
  target_id        = aws_instance.hub.id
}

resource "aws_lb_listener" "hub" {
  load_balancer_arn = aws_lb.hublb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.lb.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.hublb.arn
  }
}
