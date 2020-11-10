#!/bin/bash

####### Supporting OS : CentOS7
####### Made on November 10, 2020
####### Backend : Tomcat (If you want to run multiple tomcat host, edit this script)
####### Apache - Connector - Tomcat



# Variables
check_os=`cat /etc/*release | grep -e "^ID=" | awk -F\" '{print $2}'`

########## Please Customize your environment ##############
###########################################################
host_ip="192.168.100.20"
tomcat_ip="192.168.100.21"

#SELinux disabled
sed -i 's/^SELINUX=.*$/SELINUX=disabled/' /etc/selinux/config
setenforce 0


# Check if you are using centos7 or not
if [[ $check_os = "centos" ]]; then
	echo "-----------------------------------------------------------"
	echo "--------------------Install apache-------------------------"
else
	echo "This script only supports CentOS7"
	exit 0
fi
#You can use below too.
#elif [[ {$check_os} != centos ]]; then
#	echo "This script only supports CentOS7."
#	exit 0
#fi

# Install packages related apache
yum -y update
for package in "httpd" "httpd-devel" "gcc" "gcc-c++" "wget"
do
	yum -y install $package
done
sleep 2

# Tomcat-connector
wget http://apache.tt.co.kr/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.48-src.tar.gz

tar zvxf tomcat-connectors-1.2.48-src.tar.gz
cd tomcat-connectors-1.2.48-src/native/
apx=`which apxs`

./configure --with-apxs=/$apx
make && make install

sed -i "s/^#ServerName.*/ServerName $host_ip:80/" /etc/httpd/conf/httpd.conf

cd /etc/httpd/conf.d/

# mod_jk.conf 생성 후 설정 
cat << EOF > mod_jk.conf
LoadModule jk_module modules/mod_jk.so

JkWorkersFile conf.d/workers.properties
JkShmFile     run/mod_jk.shm
JkLogFile     logs/mod_jk.log
JkLogLevel    info
JKMountFile conf.d/uriworkermap.properties
JKLogStampFormat "[%a %b %d %H:%M:%s %Y]"
JKRequestLogFormat "%w %V %T"
EOF

# workers.properties 생성 후 설정
cat << EOF > workers.properties
worker.list=worker1
worker.worker1.type=ajp13
worker.worker1.host=$host_ip
worker.worker1.port=8009
EOF

# uriworkermap.properties 생성 후 설정
cat << EOF > uriworkermap.properties
/*.worker1
EOF

# .html, .jpg, .gif는 apache 단에서 처리
cat << EOF >> /etc/httpd/conf/httpd.conf
JkUnMount /*.html worker1
JkUnMount /*.jpg worker1
JkUnMount /*.dif worker1
EOF

apachectl configtest
retVar=$?

if [[ $retVar -ne 0 ]]; then
	echo "Something wrong"
	exit 0
fi

# firewall config
for prt in 80 8009
do
	firewall-cmd --permanent --zone=public --add-port=$prt/tcp
done
firewall-cmd --reload

# Daemon
systemctl restart httpd && systemctl enable httpd