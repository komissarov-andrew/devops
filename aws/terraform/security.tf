resource "aws_security_group" "mysql" {
  name   = "dbSG"
  vpc_id = aws_vpc.AppVPC.id

  tags = {
    name = "dbSG"
  }

  ingress {
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    security_groups = ["${aws_security_group.web.id}"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web" {
  name   = "webSG"
  vpc_id = aws_vpc.AppVPC.id

  tags = {
    name = "webSG"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    security_groups = ["${aws_security_group.elb.id}"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "elb" {
  name   = "elbSG"
  vpc_id = aws_vpc.AppVPC.id

  tags = {
    name = "elbSG"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "efs" {
  name  = "efsSG"
  vpc_id = aws_vpc.AppVPC.id

    tags = {
    name = "efsSG"
  }
  
  ingress {
    protocol    = "tcp"
    from_port   = 2049
    to_port     = 2049
    security_groups = ["${aws_security_group.web.id}"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}