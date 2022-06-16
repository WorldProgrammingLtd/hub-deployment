resource "aws_security_group" "hubdb" {
  name   = "${var.prefix}-hubdb"
  vpc_id = aws_vpc.green.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
	cidr_blocks = ["${aws_instance.hub.private_ip}/32"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.hub.private_ip}/32"]
  }

  tags = {
    Name = "${var.prefix}-hub-db"
  }
}

resource "aws_db_subnet_group" "hubdb" {
  name = "${var.prefix}-hubdb"
  subnet_ids = [aws_subnet.green-a.id,aws_subnet.green-b.id]
  tags = {
    Name = "${var.prefix}-hub-db"
  }
}

resource "aws_db_instance" "hubdb" {
  allocated_storage    = 8
  engine               = "postgres"
  identifier           = "${var.prefix}-hub-db"
  engine_version       = "13"
  instance_class       = "db.t3.medium"
  name                 = "${var.prefix}hub"
  username             = "${var.dbusername}"
  password             = "${var.dbpassword}"
  vpc_security_group_ids = [aws_security_group.hubdb.id]
  db_subnet_group_name = aws_db_subnet_group.hubdb.name
  skip_final_snapshot  = true
  publicly_accessible  = false
  storage_encrypted    = true
  tags = {
	Name = "${var.prefix}-hub-db"
  }
}

