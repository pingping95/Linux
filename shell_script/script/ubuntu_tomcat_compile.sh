#!/bin/bash

### BEGIN INIT INFO
### Provides:    Tomcat 9.0.41
### Description : Install the Tomcat Server as a source compilation
### END INIT INFO

#########################################################
#########################################################

## Set Variable of Tomcat, openjdk

#########################################################
#########################################################


TOMCAT_VERSION=9.0.41


#########################################################
#########################################################


# Exit immediately if a command exits with a non-zero status
set -e


## 1. Install JRE (Java Runtime Environment)


sudo apt-get update -y
sudo apt-get install openjdk-11-jre-headless -y


## 2. Set Environment Variable into /etc/profile

sudo bash -c 'cat >> /etc/profile' << EOF
# 1.  JAVA_HOME DIR
JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/

# 2. TOMCAT SERVER HOME DIR
CATALINA_HOME=/usr/local/tomcat

# 3. binary
PATH=$PATH:/usr/lib/jvm/java-11-openjdk-amd64/bin

export JAVA_HOME CATALINA_HOME PATH
EOF

source /etc/profile


java -version 2> /dev/null

if [ $? -ne 0 ]; then
    echo "#######################################################"
    echo ""
    echo "           OpenJDK Does not installed..                "
    echo ""
    echo "#######################################################"
    exit 0
fi




## 3. Create Tomcat user and Install Apache Tomcat

echo "################################################"
echo "################################################"
echo ""
echo "   Create Tomcat user and Install Tomcat $TOMCAT_VERSION "
echo ""
echo "################################################"
echo "################################################"
sleep 5


sudo groupadd tomcat
sudo useradd -s `which nologin | sed -n 1p` -g tomcat -d /usr/local/tomcat tomcat

cd /usr/local/src
sudo wget https://downloads.apache.org/tomcat/tomcat-9/v9.0.41/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz
sudo tar -zxvf apache-tomcat-$TOMCAT_VERSION.tar.gz
sudo mv apache-tomcat-$TOMCAT_VERSION /usr/local/tomcat



## 4. Permission
cd /usr/local
sudo chmod -R 755 tomcat
sudo chown -R tomcat:tomcat tomcat


## 5. Systemd Unit file

echo "################################################"
echo "################################################"
echo ""
echo "  Make Tomcat service to use systemctl command "
echo ""
echo "################################################"
echo "################################################"
sleep 5

sudo bash -c 'cat >> /etc/systemd/system/tomcat.service' << EOF

[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]
Type=forking
User=tomcat
Group=tomcat
ExecStart=/usr/local/tomcat/bin/startup.sh
ExecStop=/usr/local/tomcat/bin/shutdown.sh
SuccessExitStatus=143
Restart=always
RestartSec=10
UMask=0007

[Install]
WantedBy=multi-user.target

EOF


## 6. Restart Daemon

systemctl daemon-reload 
systemctl restart tomcat


echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo "################################################"
echo " "
echo " "
echo "           Installation Completed      "
echo " "
echo " "
echo "################################################"
echo " "
echo " "
echo " "
echo " "
echo " "