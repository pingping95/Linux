# PXE 기반의 CentOS 서버 자동 구축

# **PXE (Preboot Excution Environment)란?**

→ 다양한 서버 구축 기술을 적용하여 편리하게 운영체제를 설치할 수 있다. 서버들은 기본적으로 BIOS와 NIC(Network Interface Card)를 내장하고 있는데, 이 2개의 하드웨어 구성요소는 Network Bood/PXE 기술을 기본 지원한다.

# PXE 구성요소

## Server 구성요소

1. dhcpd : 설치할 클라이언트와 서버간의 동작은 DHCP 기반으로 모든 네트워크 정보를 주고 받기 때문에 반드시 필요 ( /etc/dhcp/dhcpd.conf )
2. TFTP : 설치에 필요한 서버 구성 내용과 PXE Boot 이미지는 모두 TFTP로 동작시킨다.

    ( /var/lib/tftpboot/pxelinux.cfg,

      PXE 이미지 /var/lib/tftpboot/vmlinuz,initrd.img )

3. FTP / HTTP / NFS : PXE 부트 이후 실제 리눅스 이미지를 설치하려면 서버에서 서비스를 제공해주어야 한다. 네트워크 서비스가 가능한 패키지가 있어야 하며 Web, FTP, NFS 등 지원이 가능하다.
4. Kickstart : 실제 리눅스 설치시 환경에 대해서 미리 설정하면 해당 설정파일을 참조해서 설치한다. (구성파일 - 네트워크서비스 디렉터리에 포함시킨다. centos는 root dir에 anaconda-ks.cfg 라는 파일로 샘플 파일이 존재 )

## Client 구성 요소

- BIOS/NIC : BIOS에서 Pxe Boot가 우선되거나 설정되어야 하고 NIC에서 Pxe Boot를 지원해야 한다. 거의 대부분 서버가 지원한다.

# PXE 동작 Process

![PXE%20%E1%84%80%E1%85%B5%E1%84%87%E1%85%A1%E1%86%AB%E1%84%8B%E1%85%B4%20CentOS%20%E1%84%89%E1%85%A5%E1%84%87%E1%85%A5%20%E1%84%8C%E1%85%A1%E1%84%83%E1%85%A9%E1%86%BC%20%E1%84%80%E1%85%AE%E1%84%8E%E1%85%AE%E1%86%A8%200e429084582b404a81f3cfbcc4963f3b/Untitled.png](PXE%20%E1%84%80%E1%85%B5%E1%84%87%E1%85%A1%E1%86%AB%E1%84%8B%E1%85%B4%20CentOS%20%E1%84%89%E1%85%A5%E1%84%87%E1%85%A5%20%E1%84%8C%E1%85%A1%E1%84%83%E1%85%A9%E1%86%BC%20%E1%84%80%E1%85%AE%E1%84%8E%E1%85%AE%E1%86%A8%200e429084582b404a81f3cfbcc4963f3b/Untitled.png)

- 사진 출처 : 청년정신 블로그

![PXE%20%E1%84%80%E1%85%B5%E1%84%87%E1%85%A1%E1%86%AB%E1%84%8B%E1%85%B4%20CentOS%20%E1%84%89%E1%85%A5%E1%84%87%E1%85%A5%20%E1%84%8C%E1%85%A1%E1%84%83%E1%85%A9%E1%86%BC%20%E1%84%80%E1%85%AE%E1%84%8E%E1%85%AE%E1%86%A8%200e429084582b404a81f3cfbcc4963f3b/Untitled%201.png](PXE%20%E1%84%80%E1%85%B5%E1%84%87%E1%85%A1%E1%86%AB%E1%84%8B%E1%85%B4%20CentOS%20%E1%84%89%E1%85%A5%E1%84%87%E1%85%A5%20%E1%84%8C%E1%85%A1%E1%84%83%E1%85%A9%E1%86%BC%20%E1%84%80%E1%85%AE%E1%84%8E%E1%85%AE%E1%86%A8%200e429084582b404a81f3cfbcc4963f3b/Untitled%201.png)

- 사진 출처 : 청년정신 블로그

# PXE Server 구성

## SELinux 비활성화

```bash
setenforce 0

getenforce

sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
```

## 필요한 패키지 설치

```bash
yum -y install tftp tftp-server xinetd
yum -y install vsftpd
yum -y install dhcp
yum -y install syslinux
```

## 방화벽 설정

```bash
for svc in ftp tftp dhcp proxy-dhcp
do
firewall-cmd --permanent --add-service=${svc}
done

firewall-cmd --add-port=69/tcp --permanent

firewall-cmd --add-port=69/udp --permanent

firewall-cmd --add-port=4011/udp --permanent

firewall-cmd --reload

firewall-cmd --list-all
```

## 서비스 구동 및 재부팅 시 사용할 수 있도록 설정

```bash
systemctl restart dhcpd && systemctl enable dhcpd

systemctl restart tftp && systemctl enable tftp

systemctl restart xinetd && systemctl enable xinetd

systemctl restart vsftpd && systemctl enable vsftpd
```

## dhcp 구성

- 설정파일 수정

```bash
[root@localhost ~]# cat /etc/dhcp/dhcpd.conf
#
# DHCP Server Configuration file.
#   see /usr/share/doc/dhcp*/dhcpd.conf.example
#   see dhcpd.conf(5) man page
#

ignore client-updates;

allow booting;
allow bootp;
allow unknown-clients;

default-lease-time 600;
max-lease-time 7200;
option domain-name-servers 192.168.100.10;		# name server
option ip-forwarding false;			      # disable ip-forwarding 
option mask-supplier false;		        # disable mask-supplier 
ddns-update-style interim;			        # confige for pxe service
next-server 192.168.100.10;			      # next server(TFTP Server)
filename "pxelinux.0";				         # pxelinux.0

subnet 192.168.100.0 netmask 255.255.255.0 {   
        option routers 192.168.100.1;
        range 192.168.100.101 192.168.100.199; 
}
```

## tftp 구성

- Config File 수정

    tftp 서비스 환경설정이 기본 disable = yes로 되어있음

    no로 바꾸어 서비스 활성화한다.

```bash
[root@localhost ~]# cat /etc/xinetd.d/tftp 
# default: off
# description: The tftp server serves files using the trivial file transfer \
#	protocol.  The tftp protocol is often used to boot diskless \
#	workstations, download configuration files to network-aware printers, \
#	and to start the installation process for some operating systems.
service tftp
{
	socket_type		= dgram
	protocol		= udp
	wait			= yes
	user			= root
	server			= /usr/sbin/in.tftpd
	server_args		= -s /var/lib/tftpboot
	disable			= no              ( yes -> no로 바꿔준다. )
	per_source		= 11
	cps			= 100 2
	flags			= IPv4
}
```

- 부팅 관련 파일 복사

```bash
for file in chain.c32 mboot.c32 menu.c32 pxelinux.0 memdisk
do
cp /usr/share/syslinux/${file} /var/lib/tftpboot/
done
```

- 부팅 파일 생성

```bash
mkdir -p /var/lib/tftpboot/pxelinux.cfg

[root@localhost ~]# cat /var/lib/tftpboot/pxelinux.cfg/default
# PXE Menufile
# KERNEL : PXE Kernel이 위치하는 Directory
# 별도로 지정하지 않으면 /etc/xinetd.d/tftp의 환경설정에 표기된 Path를 가져가고,
# 예제에서 처럼 추가로 넣어주면 환경설정에 표기된 Path 뒤에 추가 생성하면 된다.

# APPEND : kernel 로딩 이후 실제 PXE boot Image
# ks : kickstart가 위치한 장소 선언

default menu.c32
prompt 0timeout 30
MENU TITLE test PXE Menu
LABEL centos7_x64
MENU LABEL CentOS 7_x64
KERNEL /networkboot/centos/vmlinuz
APPEND initrd=/networkboot/centos/initrd.img inst.repo=ftp://192.168.100.20/pub/centos  ks=ftp://192.168.100.20/pub/centos/centos7.cfg
```

## FTP 구성

- iso 이미지 다운로드 & Mount

```bash
curl -o centos7.iso http://mirror.kakao.com/centos/7.8.2003/isos/x86_64/CentOS-7-x86_64-Minimal-2003.iso

mount centos7.iso /mnt
```

- 이미지 파일 FTP Service로 복사

```bash
mkdir /var/ftp/pub/centos

cp -r /mnt/* /var/ftp/pub/centos/
```

- vmlinuz, initrd 파일 TFTP로 복사

```bash
mkdir -p /var/lib/tftpboot/networkboot/centos

cp /var/ftp/pub/centos/images/pxeboot/{initrd.img,vmlinuz} /var/lib/tftpboot/networkboot/centos/
```

## FTP Service 확인

- 우선, 서비스를 재시작해주자

```bash
systemctl restart dhcpd && systemctl enable dhcpd

systemctl restart tftp && systemctl enable tftp

systemctl restart xinetd && systemctl enable xinetd

systemctl restart vsftpd && systemctl enable vsftpd
```

192.168.100.20:21/pub/centos 혹은

[ftp://192.168.100.20/pub/centos](ftp://192.168.100.10/pub/centos) 로 Host Internet Explorer에서 접근해보기

![PXE%20%E1%84%80%E1%85%B5%E1%84%87%E1%85%A1%E1%86%AB%E1%84%8B%E1%85%B4%20CentOS%20%E1%84%89%E1%85%A5%E1%84%87%E1%85%A5%20%E1%84%8C%E1%85%A1%E1%84%83%E1%85%A9%E1%86%BC%20%E1%84%80%E1%85%AE%E1%84%8E%E1%85%AE%E1%86%A8%200e429084582b404a81f3cfbcc4963f3b/Untitled%202.png](PXE%20%E1%84%80%E1%85%B5%E1%84%87%E1%85%A1%E1%86%AB%E1%84%8B%E1%85%B4%20CentOS%20%E1%84%89%E1%85%A5%E1%84%87%E1%85%A5%20%E1%84%8C%E1%85%A1%E1%84%83%E1%85%A9%E1%86%BC%20%E1%84%80%E1%85%AE%E1%84%8E%E1%85%AE%E1%86%A8%200e429084582b404a81f3cfbcc4963f3b/Untitled%202.png)

# KickStart 구성

- kickstart 파일 구성
- 권한 수정

```bash
cp anaconda-ks.cfg /var/ftp/pub/centos/centos7.cfg

chmod 755 /var/ftp/pub/centos/centos7.cfg

[root@pxe ~]# cd /var/ftp/pub/centos/

[root@pxe centos]# ls
centos7.cfg      EFI   GPL     isolinux  Packages  RPM-GPG-KEY-CentOS-7          TRANS.TBL
CentOS_BuildTag  EULA  images  LiveOS    repodata  RPM-GPG-KEY-CentOS-Testing-7
```

- 복제된 kickstart 파일을 기호에 맞게 수정한다.

```bash
[root@localhost centos]# openssl passwd -1 1234
$1$ipJkR9V/$o//jZLHOnnrJ8XanJV.JZ0

[root@pxe centos]# vim centos7.cfg 

#platform=x86, AMD64, or Intel EM64T
#version=DEVEL
# Install OS instead of upgrade
install
# Keyboard layouts
keyboard 'us'
# Root password
rootpw --iscrypted $1$ipJkR9V/$o//jZLHOnnrJ8XanJV.JZ0
# System language
lang en_US
# System authorization information
auth  --useshadow  --passalgo=sha512
# Use graphical install
graphical
firstboot --disable
# SELinux configuration
selinux --enforcing

# Firewall configuration
firewall --disabled
# Network information
network  --bootproto=dhcp --device=ens33
# Halt after installation
halt
# System timezone
timezone Asia/Seoul
# Use network installation
url --url="ftp://192.168.100.20/pub/centos"
# System bootloader configuration
bootloader --location=mbr
# Clear the Master Boot Record
zerombr
# Partition clearing information
clearpart --all
# Disk partitioning information
part /boot --fstype="xfs" --size=512
part / --fstype="xfs" --grow --size=1

%packages
@^minimal
@core
kexec-tools

%end
```

- Service 재시작

```bash
systemctl restart dhcpd

systemctl restart tftp

systemctl restart xinetd

systemctl restart vsftpd
```

## PXE를 통한 CentOS7 VM 생성

- Network Boot (PXE)를 누른다

![PXE%20%E1%84%80%E1%85%B5%E1%84%87%E1%85%A1%E1%86%AB%E1%84%8B%E1%85%B4%20CentOS%20%E1%84%89%E1%85%A5%E1%84%87%E1%85%A5%20%E1%84%8C%E1%85%A1%E1%84%83%E1%85%A9%E1%86%BC%20%E1%84%80%E1%85%AE%E1%84%8E%E1%85%AE%E1%86%A8%200e429084582b404a81f3cfbcc4963f3b/Untitled%203.png](PXE%20%E1%84%80%E1%85%B5%E1%84%87%E1%85%A1%E1%86%AB%E1%84%8B%E1%85%B4%20CentOS%20%E1%84%89%E1%85%A5%E1%84%87%E1%85%A5%20%E1%84%8C%E1%85%A1%E1%84%83%E1%85%A9%E1%86%BC%20%E1%84%80%E1%85%AE%E1%84%8E%E1%85%AE%E1%86%A8%200e429084582b404a81f3cfbcc4963f3b/Untitled%203.png)

- 아..

    ![PXE%20%E1%84%80%E1%85%B5%E1%84%87%E1%85%A1%E1%86%AB%E1%84%8B%E1%85%B4%20CentOS%20%E1%84%89%E1%85%A5%E1%84%87%E1%85%A5%20%E1%84%8C%E1%85%A1%E1%84%83%E1%85%A9%E1%86%BC%20%E1%84%80%E1%85%AE%E1%84%8E%E1%85%AE%E1%86%A8%200e429084582b404a81f3cfbcc4963f3b/Untitled%204.png](PXE%20%E1%84%80%E1%85%B5%E1%84%87%E1%85%A1%E1%86%AB%E1%84%8B%E1%85%B4%20CentOS%20%E1%84%89%E1%85%A5%E1%84%87%E1%85%A5%20%E1%84%8C%E1%85%A1%E1%84%83%E1%85%A9%E1%86%BC%20%E1%84%80%E1%85%AE%E1%84%8E%E1%85%AE%E1%86%A8%200e429084582b404a81f3cfbcc4963f3b/Untitled%204.png)

    ![PXE%20%E1%84%80%E1%85%B5%E1%84%87%E1%85%A1%E1%86%AB%E1%84%8B%E1%85%B4%20CentOS%20%E1%84%89%E1%85%A5%E1%84%87%E1%85%A5%20%E1%84%8C%E1%85%A1%E1%84%83%E1%85%A9%E1%86%BC%20%E1%84%80%E1%85%AE%E1%84%8E%E1%85%AE%E1%86%A8%200e429084582b404a81f3cfbcc4963f3b/Untitled%205.png](PXE%20%E1%84%80%E1%85%B5%E1%84%87%E1%85%A1%E1%86%AB%E1%84%8B%E1%85%B4%20CentOS%20%E1%84%89%E1%85%A5%E1%84%87%E1%85%A5%20%E1%84%8C%E1%85%A1%E1%84%83%E1%85%A9%E1%86%BC%20%E1%84%80%E1%85%AE%E1%84%8E%E1%85%AE%E1%86%A8%200e429084582b404a81f3cfbcc4963f3b/Untitled%205.png)

    - References

        [CentOS 강좌 PART 2. 10 PXE기반의 CentOS 서버 자동 구축 1편](https://youngmind.tistory.com/entry/CentOS-%EA%B0%95%EC%A2%8C-PART-2-10-PXE%EA%B8%B0%EB%B0%98%EC%9D%98-CentOS-%EC%84%9C%EB%B2%84-%EC%9E%90%EB%8F%99-%EA%B5%AC%EC%B6%95-1%ED%8E%B8)
