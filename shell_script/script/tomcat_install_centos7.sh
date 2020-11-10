#!/bin/bash
#########################################################################
############# Supporting OS : CentOS7 ###################################
############# Made on November 10, 2020 #################################
############# Tomcat Version : apache-tomcat-8.5.59 #####################
#########################################################################

# Variables
check_os=$(cat /etc/*release | grep -e "^ID=" | awk -F\" '{print $2}')

################## Customize your environment #####################
##########################################################################
# host_ip="192.168.100.20"

# SELinux disabled
sed -i 's/^SELINUX=.*$/SELINUX=disabled/' /etc/selinux/config
setenforce 0


# Check if you are using centos7 or not
if [[ $check_os = "centos" ]]; then
	echo "-----------------------------------------------------------"
	echo "------------------Install tomcat-8.5.59--------------------"
	sleep 5
else
	echo "This script only supports CentOS7"
	exit 0
fi

## Install openjdk
yum -y install java-1.8.0-openjdk.x86_64 wget
java -version
retVar=$?
if [[ $retVar -ne 0 ]]; then
	echo "Something wrong"
	exit 0
fi

j_home=$(readlink -f /usr/bin/java | awk -F/jre '{print $1}')

cat << EOF >> /etc/profile
####JAVA1.8####
JAVA_HOME=$j_home
PATH=$PATH:$JAVA_HOME/bin
CLASSPATH=$JAVA_HOME/jre/lib:$JAVA_HOME/lib/tools.jar
CATALINA_HOME=/opt/tomcat

export JAVA_HOME PATH CLASSPATH CATALINA_HOME
EOF

source /etc/profile

# Move directory to /opt
# If fails, do 'exit 0'
cd /opt || exit 0

## Version : apache-tomcat-8.5.59
## Get tar.gz file from internet and uncompress it using tar utility
## change directory name, this will match $CATALINA_HOME
wget https://downloads.apache.org/tomcat/tomcat-8/v8.5.59/bin/apache-tomcat-8.5.59.tar.gz
tar xvf apache-tomcat-8.5.59.tar.gz
mv apache-tomcat-8.5.59 tomcat
sleep 2

## generate tomcat user
useradd -G wheel tomcat
echo password | passwd tomcat --stdin
chown -R tomcat:tomcat /opt/tomcat

## Register Service
cat << EOF > /usr/lib/systemd/system/tomcat.service
[Unit]
Description=tomcat
After=syslog.target

[Service]
Type=forking
User=tomcat
Group=tomcat
ExecStart=$CATALINA_HOME/bin/startup.sh
ExecStop=$CATALINA_HOME/bin/shutdown.sh
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target
EOF



## For the test
cat << EOF > "$CATALINA_HOME"/webapps/ROOT/index.jsp
<%@page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<html>
    <head>
        <title>$HOSTNAME</title>
    </head>
    <body>
        <h1><font color="red">Session serviced by tomcat</font></h1>
        <table aligh="center" border="1">
        <tr>
            <td>Session ID</td>
            <td><%=session.getId() %></td>
                <% session.setAttribute("abc","abc");%>
            </tr>
            <tr>
            <td>Created on</td>
            <td><%= session.getCreationTime() %></td>
            </tr>
        </table>
    $HOSTNAME
    </body>
<html>
EOF

## Open Firewall
for port in 8009 8080 8443
do
	firewall-cmd --permanent --zone=public --add-port=$port/tcp
done
firewall-cmd --reload

## Service start
systemctl restart tomcat && systemctl enable tomcat