resource "aws_efs_file_system" "efs" {
  creation_token = "w_efs"
  tags = {
    Name = "wordpress-EFS"
  }
}

resource "aws_efs_mount_target" "mount_efs_1" {
  depends_on = [aws_efs_file_system.efs]
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = aws_subnet.aws-subnet-public-1.id
  security_groups = ["${aws_security_group.efs.id}"]
}

resource "aws_efs_mount_target" "mount_efs_2" {
  depends_on = [aws_efs_file_system.efs]
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = aws_subnet.aws-subnet-public-2.id
  security_groups = ["${aws_security_group.efs.id}"]
}