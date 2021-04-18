resource "aws_elb" "elb" {
  name    = "elb"
  subnets = ["${aws_subnet.aws-subnet-public-1.id}", "${aws_subnet.aws-subnet-public-2.id}"]
  security_groups = [ "${aws_security_group.elb.id}" ]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/wp-admin/install.php"
    interval            = 30
  }

  instances                   = ["${aws_instance.wp1.id}","${aws_instance.wp2.id}"]
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "elb"
  }
}