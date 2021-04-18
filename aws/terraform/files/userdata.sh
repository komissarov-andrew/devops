#!/bin/bash
sudo yum install -y httpd amazon-efs-utils nfs-utils
sudo service httpd start
sudo systemctl enable httpd
sudo chmod ugo+rw /etc/fstab
sudo amazon-linux-extras install -y php7.2