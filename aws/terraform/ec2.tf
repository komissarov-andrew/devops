resource "aws_key_pair" "keypair1" {
  key_name   = "keypairs"
  public_key = file(var.ssh_key)
}

data "template_file" "phpconfig" {
  template = file("files/conf.wp-config.php")
  
  vars = {
    db_port = aws_db_instance.mysql.port
    db_host = aws_db_instance.mysql.address
    db_user = var.db_user
    db_pass = var.db_password
    db_name = var.db_name
  }
}
resource "aws_db_instance" "mysql" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  name                   = var.db_name
  username               = var.db_user
  password               = var.db_password
  parameter_group_name   = "default.mysql5.7"
  vpc_security_group_ids = [aws_security_group.mysql.id]
  db_subnet_group_name   = aws_db_subnet_group.mysql_group.name
  skip_final_snapshot    = true
}

resource "aws_instance" "wp1" {
  ami = "${var.instance_ami}"
  availability_zone = "${var.aws_region}a"
  associate_public_ip_address = true
  instance_type = "t2.micro"
  depends_on = [
    aws_db_instance.mysql,
    aws_efs_file_system.efs,
    aws_efs_mount_target.mount_efs_1,

  ]
  key_name = "${aws_key_pair.keypair1.key_name}"
  subnet_id = "${aws_subnet.aws-subnet-public-1.id}"
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data = file("files/userdata.sh")

  tags = {
    Name = "Webserver_1"
  }
  
  provisioner "file" {
    source      = "files/userdata.sh"
    destination = "/tmp/userdata.sh"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host = self.public_ip
      private_key = file(var.ssh_priv_key)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/userdata.sh",
      "/tmp/userdata.sh",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host = self.public_ip
      private_key = file(var.ssh_priv_key)
    }
  }

  provisioner "remote-exec" {
    inline =  [
      "sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs.dns_name}:/  /var/www/html",
      "echo ${aws_efs_file_system.efs.dns_name}:/ /var/www/html nfs4 defaults,_netdev 0 0  | sudo cat >> /etc/fstab " ,
      "wget http://wordpress.org/latest.tar.gz",
      "tar -xzf latest.tar.gz",
      "sudo mkdir -p /var/www/html/",
      "sudo cp -r wordpress/* /var/www/html/",
      "sudo chown -R apache:apache /var/www/html", 
      "sudo chmod -R 755 /var/www/html/",
      "sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php",

    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host = self.public_ip
      private_key = file(var.ssh_priv_key)
    }
  }

  provisioner "file" {
    content     = data.template_file.phpconfig.rendered
    destination = "/tmp/wp-config.php"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host = self.public_ip
      private_key = file(var.ssh_priv_key)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /tmp/wp-config.php /var/www/html/wp-config.php",
      "sudo systemctl restart httpd",
      
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host = self.public_ip
      private_key = file(var.ssh_priv_key)
    }
  }

  timeouts {
    create = "20m"
  }
}

resource "aws_instance" "wp2" {
  ami = "${var.instance_ami}"
  availability_zone = "${var.aws_region}b"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  depends_on = [
    aws_db_instance.mysql,
    aws_efs_file_system.efs,
    aws_efs_mount_target.mount_efs_1,
    
  ]
  key_name = "${aws_key_pair.keypair1.key_name}"
  subnet_id = "${aws_subnet.aws-subnet-public-2.id}"
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data = file("files/userdata.sh")

  tags = {
    Name = "Webserver_2"
  }

  provisioner "file" {
    source      = "files/userdata.sh"
    destination = "/tmp/userdata.sh"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host = self.public_ip
      private_key = file(var.ssh_priv_key)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/userdata.sh",
      "/tmp/userdata.sh",

    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host = self.public_ip
      private_key = file(var.ssh_priv_key)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs.dns_name}:/  /var/www/html",
      "echo ${aws_efs_file_system.efs.dns_name}:/ /var/www/html nfs4 defaults,_netdev 0 0  | sudo cat >> /etc/fstab " ,
      "sudo systemctl restart httpd",

    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host = self.public_ip
      private_key = file(var.ssh_priv_key)
    }
  }

  timeouts {
    create = "20m"
  }
}
