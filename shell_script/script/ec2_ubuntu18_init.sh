#!/bin/bash

## Description
## Ubuntu 18.04 전용 스크립트입니다.
## 기타 OS에서는 정상 작동되지 않습니다.
## id와 pw를 기입해주어야 합니다.


# update Package Manager
apt-get update -y

# 생성할 user의 id와 pw 기입
id='test'
pw='1234'
shellPath=$(which bash | sed -n 1p)

# User 생성
# User 없을 시 아래 if문을 실행하지 않음
if [ -n "$id" ] && [ -n "$pw" ]; then
  sudo useradd -m -s "$shellPath" $id
  sudo bash -c "echo '$id:$pw' | chpasswd"
  sudo usermod -aG admin $id
fi

# Timezone 변경
sudo rm -rf /etc/localtime
sudo ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime


# password 접속 허용
sudo sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sudo service sshd restart


# Amazon Time Sync Service 설정
# Internet 연결되어 있어야 함
sudo apt-get install chrony -y
sudo bash -c "echo 'server 169.254.169.123 prefer iburst minpoll 4 maxpoll 4' \
 >> /etc/chrony/chrony.conf"
sudo /etc/init.d/chrony restart
sudo systemctl enable chrony