# 티밍, SELinux

- 티밍과 본딩의 차이

    Teaming : User Level에서 이루어지는 작업, 보통 Windows에서 작용

    Bonding : Kernel Level에서 이루어지는 작업, 보통 Linux에서 작용

# 티밍


![Untitled](https://user-images.githubusercontent.com/67780144/95008429-c100b280-0654-11eb-8827-35ac8068213e.png)

- 여러 개의 Physical Interface를 하나의 Logical Interface로 구성하는 네트워크 구성 방식
- RHEL 7부터 nmcli를 통해 NIC Teaming를 사용할 수 있게 되었다.
- 티밍을 활성화하려면 팀 인터페이스에 연결된 포트 인터페이스들이 활성화되어야 한다. 연결을 해제하려면 팀 인터페이스를 비활성화해야 한다. 팀 인터페이스를 비활성화하면 포트 인터페이스도 자동으로 연결이 해제된다.
1. 러너

: 처리 방식을 결정해주는 것, 러너를 지정할 때는 JSON (Java Script Object Notation)을 사용한다.

[ 형식 ]

'{"runner":{"name";"METHOD"}}'

- 러너가 지원하는 방식

    broadcast

    roundrobin

    loadbalance

    activebackup

    lacp

```bash
# eth0, eth1 생성
nmcli connection add con-name eth0-team ifname eth0 type ethernet
nmcli connection add con-name eth1-team ifname eth1 type ethernet

# 팀 인터페이스 (team0) 생성, runner type : roundrobin
nmcli connection add con-name team0 ifname team0 type team config '{"runner":{"name":"roundrobi
n"}}'

# 팀 인터페이스 ip address, method, dns 변경
nmcli connection modify team0 ipv4.addresses 192.168.122.50/24

nmcli connection modify team0 ipv4.method manual

nmcli connection modify team0 ipv4.dns 8.8.8.8

# slave : eth1, master : team0
nmcli connection add type team-slave ifname eth1 con-name team0-port1 master team0

# slave : eth0, master : team0
nmcli connection add type team-slave ifname eth0 con-name team0-port2 master team0

# 물리적 인터페이스 활성화
nmcli connection up team0-port1

nmcli connection up team0-port2

# 팀 인터페이스 활성화
nmcli connection up team0

# 확인
nmcli connection show
```

# SELinux

- 리눅스의 보안을 강화
- MAC사용 (원래는 DAC모델을 사용했지만 사용자의 권한을 기반으로 파일이나 자원에 대한 접근을 허용하다보니 보안에 취약)

- MAC

→ 사용자, 파일, 포트, .. 에 대한 정책 부여

→ 주체 : 시스템 자원에 접근하는 Process 또는 User 등을 의미

→ 객체 : File 또는 Port 같은 시스템 Resource

→ 정책 : context

- SELinux의 파일 접근 방식

process(httpd_t)  - - 접근 - - > file1(httpd_sys_t)

l

— - - - - - - - 접근 불가 - > file2 (mysql_db_t)

- 사용자 관점에서 보면 프로세스가 특정 리소스(파일, 디렉터리, 소켓 등)를 요청하면 기존의 임의 접근 통제 방식의 권한이 부여되어 있는지 확인하고 다시 SELinux 내의 강제 접근 통제(MAC) 에서도 허용된 요청인지를 보안 Context를 통해 확인하고 이를 통과하면 접근을 허용하게 된다.

![Untitled 1](https://user-images.githubusercontent.com/67780144/95008432-c1994900-0654-11eb-8eef-4dafd9cf2cfa.png)


- SELinux 모드

→ Disable 모드 : SELinux 커널 모듈을 메모리에 로드하지 않기 때문에 SELinux가 비활성화 된다.

→ Enforcing 모드 : SELinux 커널 모듈을 메모리에 로드한 상태로 활성화하며 정책을 강제한다.

→ Permissive 모드 : SELinux 커널 모듈을 메모리에 로드한 상태지만 정책을 강제하지 않는다.

### SELinux 컨텍스트

- ps axZ

```bash
[root@localhost ~]# ps axZ
LABEL                             PID TTY      STAT   TIME COMMAND
system_u:system_r:init_t:s0         1 ?        Ss     0:03 /usr/lib/systemd/systemd --switched-root --system --de
system_u:system_r:kernel_t:s0       2 ?        S      0:00 [kthreadd]
system_u:system_r:kernel_t:s0       4 ?        S<     0:00 [kworker/0:0H]
system_u:system_r:kernel_t:s0       5 ?        S      0:00 [kworker/u2:0]
system_u:system_r:kernel_t:s0       6 ?        S      0:00 [ksoftirqd/0]
system_u:system_r:kernel_t:s0       7 ?        S      0:00 [migration/0]
system_u:system_r:kernel_t:s0       8 ?        S      0:00 [rcu_bh]
system_u:system_r:kernel_t:s0       9 ?        R      0:00 [rcu_sched]
system_u:system_r:kernel_t:s0      10 ?        S<     0:00 [lru-add-drain]
```

- ls -dZ

```bash
[root@localhost ~]# ls -dZ /var/www/html/
drwxr-xr-x. root root system_u:object_r:httpd_sys_content_t:s0 /var/www/html/
```

**사용자 : 역할 : 유형 : 레벨**

>> 사용자 : SELinux 사용자를 의미함. 사용자는 역할, 레벨 등과 함께 자원이나 파일에 대한 접근을 제어한다.

>> 역할(Role) : SELinux의 일부는 RBAC 모델을 사용한다. 이 역할은 RBAC 모델의 특징 중 하나임.

>> 유형 : 주체가 객체에 접근하려고 할 때, 컨텍스트를 비교하기 위해 사용된다.

>> 레벨 (Level) : 컨텍스트의 레벨 부분은 MLS(Multi Level Security)정책을 사용하여 보안성을 더욱 강화할 때 사용한다.
