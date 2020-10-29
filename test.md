# Disconnect Openshift Container Platform 구축 및 CI/CD Pipeline
## OpenShift Conatiner Platform 4.4.17
### Installing a cluster on bare metal in a disconnected network
## 프로젝트 목표

**1. PaaS 클라우드 구축**

일반적으로 고객사들은 자사의 보안을 위해 외부와 인터넷이 단절된, 즉 disconnected 환경에서 클라우드 Platform을 구축한다. 본 프로젝트를 통해 이러한
 Disconnected 환경에서 Openshift 기반의 PaaS 클라우드 아키텍쳐를 수립하고 환경을 구축한다. PaaS 클라우드를 구축하기 위한 사전 준비 사항 및 고려 사항을 파악하고 전체적인 아키텍처에 대해 이해한다. 

**2. DevSecOps Pipeline 구성**

환경 및 데이터 보안, CI/CD 프로세스 및 보안을 고려한 DevSecOps Pipeline을 구성하고 Jenkins, Gitlab, Quay 등을 연계하여 PaaS 클라우드 환경에서 빌드 및 배포의 자동화를 구성한다.  
<br></br>

## 주요 내용

**1. Disconnected 환경에서의 기초 인프라 Architecture 설계 및 구축**
- 기반 서비스 (DNS, Haproxy, Chrony, Yum Repository, Image-Registry) 설계와 구축
- 애플리케이션 서비스 (Gitlab, Image Registry) 설계와 구축

**2. 표준 컨테이너 및 오케스트레이션 기술 이해**
- 프라이빗 PaaS 클라우드 (Openshift 4) 아키텍쳐 설계 및 구축
- Master, Infra, Router, App Node 설계와 구축

**3. GitLab, Jenkins, Quay 등을 활용한 DevSecOps Pipeline 설계와 구축**
- 사용자 ID 권한 부여 및 Access 제어
- 컨테이너 분리 및 네트워크 분리
- 컨테이너 이미지 스캔

<br></br>
## 프로젝트 인프라 구성 환경



**1. 리소스 구성**
- 노트북 5대, Hub 1대,  LAN Cable 5개
- Ubuntu 18.04 (RHEL 추천)
- 5 Core, RAM 16 GB, SSD 512 GB
- KVM 
<br>

**2.네트워크 구성**
- Host <—> 다른 Host의 VM : Bridge 통신
- Host <—> 본인 Guest VM  : Host-Only 통신

<br></br>
# Architecture


**1. 논리적 Architecture**

- Quay 폐쇄망에서 구축할 수 있는 버전이 아직 나오지 않아 폐쇄망 외부에 구축하였음

![논리 아키텍쳐](https://user-images.githubusercontent.com/67780144/97079200-e584f480-162c-11eb-86ea-915973f4d499.png)

**2.. 물리적 Architecture**

- 각 VM의 리소스 할당량을 고려하여 배치
- Com #3의 경우 Bootstrap은 Master Node 설치 후 삭제가능하므로, 구축 완료 후 삭제하고 Infra #2, Router Node 배치

![물리 아키텍쳐 (1)](https://user-images.githubusercontent.com/67780144/97079199-e3bb3100-162c-11eb-93b8-393b42cd952a.png)
**3. 노드별 Resource, IP 구성**

- Cluster Name : redhat2
- Base Domain : cccr.local
- Openshift Service network : 172.30.0.0/16
- cluster network ( Pod ) : 10.1.0.0/16


<table>
<thead>
    <tr>
        <th>구분</th>
        <th>서버명</th>
        <th> OS 구분 </th>
        <th>Hostname<br>(Domain).redhat2.cccr.local</th>
        <th>IP</th>
        <th>vcpu<br>(core)</th>
        <th>Memory<br>(GB)</th>
        <th>OS (GB)</th>
        <th>contaimer<br>Runtime (GB)</th>
    </tr>
</thead>
<tbody>
    <tr>
        <td rowspan=7>컨테이너<br>관리노드</td>
        <td>BootStrap</td>
        <td>RHCOS 4.4</td>
        <td align="center">bootstrap</td>
        <td>10.10.10.10</td>
        <td align="center">4</td>
        <td align="center">16</td>
        <td align="center">120</td>
        <td align="center">100</td>
    </tr>
    <tr>
        <td>Master #1</td>
        <td>RHCOS 4.4</td>
        <td align="center">master-1</td>
        <td>10.10.10.11</td>
        <td align="center">4</td>
        <td align="center">8</td>
        <td align="center">100</td>
        <td align="center">100</td>
    </tr>
    <tr>
        <td>Master #2</td>
        <td>RHCOS 4.4</td>
        <td align="center">master-2</td>
        <td>10.10.10.12</td>
        <td align="center">4</td>
        <td align="center">8</td>
        <td align="center">100</td>
        <td align="center">100</td>
    </tr>
    <tr>
        <td>Master #3</td>
        <td>RHCOS 4.4</td>
        <td align="center">master-3</td>
        <td>10.10.10.13</td>
        <td align="center">4</td>
        <td align="center">8</td>
        <td align="center">100</td>
        <td align="center">100</td>
    </tr>
    <tr>
        <td>Infra #1 </td>
        <td>RHCOS 4.4</td>
        <td align="center">infra-1</td>
        <td>10.10.10.14</td>
        <td align="center">4</td>
        <td align="center">8</td>
        <td align="center">100</td>
        <td align="center">100</td>
    </tr>
    <tr>
        <td>Infra #2</td>
        <td>RHCOS 4.4</td>
        <td align="center">infra-2</td>
        <td>10.10.10.15</td>
        <td align="center">4</td>
        <td align="center">8</td>
        <td align="center">100</td>
        <td align="center">100</td>
    </tr>
    <tr>
        <td>Router</td>
        <td>RHCOS 4.4</td>
        <td align="center">router</td>
        <td>10.10.10.16</td>
        <td align="center">2</td>
        <td align="center">3</td>
        <td align="center">100</td>
        <td align="center">100</td>
    </tr>
    <tr>
        <td>주변시스템</td>
        <td>Bastion</td>
        <td>RHCOS 4.4</td>
        <td align="center">bastion</td>
        <td>10.10.10.17</td>
        <td align="center">4</td>
        <td align="center">8</td>
        <td align="center">100</td>
        <td align="center">100</td>
    </tr>
    <tr>
        <td rowspan=3>컨테이너<br>업무서버 </td>
        <td>Service #1</td>
        <td>RHCOS 4.4</td>
        <td align="center">service-1</td>
        <td>10.10.10.18</td>
        <td align="center">2</td>
        <td align="center">4</td>
        <td align="center">100</td>
        <td align="center">100</td>
    </tr>
    <tr>
        <td>Service #2</td>
        <td>RHCOS 4.4</td>
        <td align="center">service-2</td>
        <td>10.10.10.19</td>
        <td align="center">2</td>
        <td align="center">4</td>
        <td align="center">100</td>
        <td align="center">100</td>
    </tr>
    <tr>
        <td>Quay</td>
        <td>RHEL 7.8</td>
        <td align="center">quay</td>
        <td>10.10.10.21</td>
        <td align="center">3</td>
        <td align="center">8</td>
        <td align="center">100</td>
        <td align="center">100</td>
    </tr>
</tbody>
</table>

**4. 노드별 역할**

- Bastion Node : Openshift 4 Container Platform 구축의 기반이 되는 노드로서, DNS/ HAProxy/ Image Registry/ Chrony/ Yum Repository 을 포함
- Master Node : Openshift 4 Control Plane Node, 고가용성을 위해 반드시 3중화 이상으로 구성 
- Router Node : Application이 배포될 서비스 노드로 라우팅하는 노드
- Infra Node : Logging, Monitoring, CI/CD 구성을 위한 노드
- Service Node : 실질적인 Application이 배포되는 Node
- Quay Node : OpenShift 컨테이너 이미지 레지스트리인 Quay와 이미지 보안 스캐닝을 위한 Clair 구성을 위한 노드

# Disconnected 환경에서 Openshift 설치를 위한 사전준비

## 개요

Disconnected 환경에서는 Openshift 설치에 필요한 파일, 설치 이미지 및 패키지를 인터넷을 통해 다운 받을 수 없다. 따라서 disconnected 환경에서 OCP 를 구축하기 위하여 사전에 필요한 모든 것을 미리 준비하고 이를 disconnected 환경으로 옮겨와 설치를 시작한다. 
우선, 인터넷이 되는 임시 vm 을 통해 필요한 것들을 다운 받는 것으로 설치 준비를 시작해보자.  
<br></br>

## 임시 vm 준비 
**1. 인터넷 환경에서 임시 RHEL 7.8 disk vm 사용**

- 설치에 필요한 파일 준비와 Private registry, Yum repository를 동기화 하기 위해 임시 VM을 사용

- 설치 디스크 파일 아래 링크에서 다운받아 usb에 저장하여 준비

    - bastion node에서 사용할 [RHEL 7.8 DVD ISO 파일](https://access.redhat.com/downloads/content/69/ver=/rhel---7/7.8/x86_64/product-software) 
        
    - master, bootstrap 등의 node 부팅 시 사용되는 [RHCOS 4.4.17 (ISO, RAW) 파일](https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.4/4.4.17/)

- 설치 도구 준비

    - oc CLI Tool(openshift-client 4.4.17)   

    - Red Hat Pull-secret token  

    - openshift-install 4.4.17 바이너리 프로그램 파일


**2. 임시 vm 방화벽 차단**
- 폐쇄망 환경에선 방화벽이 필요 없으므로 Fiewall Deamon 사용 안 함
    ```
    systemctl disable --now firewalld.service
    ```

**3. 임시 VM에서 Redhat Subscription을 통한 Redhat repository 등록**
- Redhat 계정정보를 통해 기본 redhat repository를 등록하여 사용

    ```bash
    subscription-manager register --username=<USER_NAME> --password=<PASS_WORD>
    subscription-manager refresh
    subscription-manager list --available --matches '*OpenShift*'
    subscription-manager attach --pool=<POOL_ID>
    subscription-manager repos --disable="*"
    subscription-manager repos \
        --enable="rhel-7-server-rpms" \
        --enable="rhel-7-server-extras-rpms" \
        --enable="rhel-7-server-ose-4.4-rpms"
    ```
<br></br>
## Disconnected 환경에서 Bastion node 준비
- RHEL 7.8 DVD ISO 부트 
- 폐쇄망 환경에선 방화벽이 필요 없으므로 방화벽 사용 안 함
    ```
    systemctl disable --now firewalld.service
    ```
# Disconnected 환경에서 Openshift 설치를 위한 구성요소 설치 
### 개요

사전 준비를 끝내고 본격적으로 Openshift 설치를 시작한다. Disconnected 환경에서 Openshift를 설치하고 사용하기 위하여 다음과 같은 구성 요소들을 설치한다. 

> Private Registry <br>
> Yum repository <br>
> DNS <br>
> Chrony <br>
> Haproxy 

<br></br>
# Private Registry

### 목적

인터넷이 되지 않는 disconnected 환경에서는 설치에 필요한 이미지를 인터넷에서 가져올 수 없다. 따라서, 폐쇄망 내에 Private Registry를 구축하여 OCP 설치에 필요한 이미지들을 사용하도록 한다. 또한, Operator 이미지를 사용하여 폐쇄망에서 클러스터를 구성한다. 
<br></br>
## 인터넷 환경에서 진행

**1. OpenShfit CLI( oc ) 설치**
  -  [Infrastructure Provider](https://cloud.redhat.com/openshift/install) 에서 oc 다운로드
  - 다운로드한 압축파일 해제

    ```bash
    tar -xvzf <file>
    ```

- PATH 설정

    ```bash
    cp ./oc /usr/local/bin/
    cp ./kubectl /usr/local/bin/
    ```

**2. httpd-tools, podman 설치**
- httpd-tools를 통해 htpasswd 프로그램 사용
- 컨테이너 런타임인  podman을 통해 mirror registry 이미지 생성

  ```bash
  yum -y install podman httpd-tools
  ```

**3. jq 설치**
- pull-secret을 json 형식으로 저장하기 위하여 설치

    ```bash
    curl -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o /usr/local/bin/jq
    chmod a+x /usr/local/bin/jq
    ```

**4. 작업 Directory 생성**
- 원하는 경로에 auth, data, certs 세가지 Directory를 생성 

    ```bash
    mkdir -p /opt/registry/{auth,data,certs}
    ```

**5. OpenSSL 인증서 생성**
- Private registry의 보안을 위해 openssl 명령어로 인증서를 생성하여 사용
- bastion의 호스트네임과 pull-secret을 받은 RedHat 이메일 계정 정보 사용

    ```bash
    cd /opt/registry/certs
    openssl req -newkey rsa:4096 -nodes -sha256\
     -keyout domain.key -x509 -days 3650 -out domain.crt

    cp /opt/registry/certs/domain.crt /etc/pki/ca-trust/source/anchors/
    update-ca-trust extract
    ```

**6. private registry에 등록할 계정 생성 및  base64 인코딩**
- Redhat mirror registry에서 private registry로 mirroring 할 수 있도록 credentials 생성
- /opt/registry/auth/htpasswd 파일에 credentials 등록
- base64로 인코딩한 credentials 확인 및 저장

    ```bash
    htpasswd -bBc /opt/registry/auth/htpasswd <USER_NAME> <PASSWORD>

    echo -n '<USER_NAME>:<PASSWORD>' | base64 -w0 
    BGVtbYk3ZHAtqXs=  # credentials
    ```

**7. pull-secret 다운 및 JSON 포맷 변환**
- [Red Hat Openshift Cluster Manager 홈페이지](https://cloud.redhat.com/openshift/install/metal/user-provisioned)에서 pull-secret 다운로드
- 다운로드한 pull-secret 과 동일한 내용의 파일 생성
- pull-secret은 24시간 동안만 유효함을 주의 

    ```bash
    vim pull-secret 
    ...
    "auth": {...
    ...

    cat pull-secret | jq . > ./pull-secret.json
    vim pull-secret.json
    ...
    	"auths": {
    	...
        "<local_registry_host_name>:<local_registry_host_port>": { 
          "auth": "<credentials>", 
          "email": "REDHAT_ACCOUNT_EMAIL"
      },
    	...
    ...
    ```

**8. Private registry 컨테이너 생성**
- 컨테이너 생성 

    ```bash
    podman run --name mirror-registry -p 5000:5000 \
    -v /opt/registry/data:/var/lib/registry:z \
    -v /opt/registry/auth:/auth:z \
    -v /opt/registry/certs:/certs:z \
    -e "REGISTRY_AUTH=htpasswd" \
    -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
    -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
    -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
    -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
    -e REGISTRY_COMPATIBILITY_SCHEMA1_ENABLED=true \
    -d docker.io/library/registry:2
    ```

- 확인 ( 아직 아무 이미지도 넣지 않았으므로 빈 repository가 나오면 맞다 )

    ```bash
    curl -u <USERNAME:PASSWORD> -k https://<local_registry_host_name>:<local_registry_host_port>/v2/_catalog
    {"repositories":[]}
    ```

**9. Mirroring (Redhat registry → Private Registry)**
- 미러링에 필요한 환경변수 설정
- OpenShift Release version 확인은 [Repository Tags](https://quay.io/repository/openshift-release-dev/ocp-release?tab=tags)에서 진행 

    ```bash
    export OCP_RELEASE=<release_version> 
    export LOCAL_REGISTRY='<local_registry_host_name>:<local_registry_host_port>' 
    export LOCAL_REPOSITORY='<local_repository_name>' 
    export PRODUCT_REPO='openshift-release-dev' 
    export LOCAL_SECRET_JSON='<path_to_pull_secret>' 
    export RELEASE_NAME="ocp-release" 
    export ARCHITECTURE=<server_architecture> 
    ```

- 미러링

    ```bash
    oc adm -a ${LOCAL_SECRET_JSON} release mirror \
         --from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE} \
         --to=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY} \
         --to-release-image=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE}-${ARCHITECTURE} --dry-run
    ```

- 미러링 출력 결과 중 imageContentSources 부분 저장 ( install-config.yaml에 사용)

    ```bash
    # Example 
    ...
    imageContentSources:
    - mirrors:
      - bastion.redhat2.cccr.local:5000/ocp4/openshift4
      source: quay.io/openshift-release-dev/ocp-release
    - mirrors:
      - bastion.redhat2.cccr.local:5000/ocp4/openshift4
      source: quay.io/openshift-release-dev/ocp-v4.0-art-dev
    ...
    ```

**10. 미러링한 콘텐츠 바탕으로 openshift-install 바이너리 프로그램 파일 생성**

```bash
oc adm -a ${LOCAL_SECRET_JSON} release extract --command=openshift-install "${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE}-${ARCHITECTURE}"
```

**11. 미러링한 이미지 및 설치도구 압축 및 저장** 
- 이미지 및 설치 도구 압축
- 설치 도구 : pull-secret, OpenShift Client( oc ), kubectl, openshift-install

    ```bash
    tar -czvf <INSTALL_FILE>.tar.gz oc kubectl /opt/* openshift-install
    ```

- podman image save

    ```bash
    podman images
    podman save -o <PODMAN_IMAGE>.tar docker.io/library/registry:2
    ```

- USB에 저장 

    ```bash
    mount <DISK> <MOUNTPOINT>
    mv <FILE_NAME>.tar.gz <MOUNTPOUINT>
    mv <FILE_NAME>.tar <MOUNTPOINT>
    ```
<br></br>
## Disconnected 환경에서 진행

**1. Host에서 Bastion으로 tar파일 전송**

```bash
scp <LOCAL_HDD_MOUNT_POINT>/<INSTALL_FILE>.tar.gz root@<BASTION IP>:/opt
scp <LOCAL_HDD_MOUNT_POINT>/<PODMAN_IMAGE>.tar root@<BASTION'S IP>:~/
```

**2. 압축 해제 및 podman load**
- 압축 해제 

    ```bash
    tar -xzvf /opt/<INSTALL_FILE>.tar.gz
    oc
    kubectl
    openshift-install
    ./auth
    ./certs
    ./data
    ```

- podman load
    ```bash
    podman load -i <PODMAN_IMAGE>.tar
    REPOSITORY           TAG               IMAGE ID            CREATED        SIZE
    ...                  ...               2d4f....
    ```

**3. Private registry 컨테이너 생성**
- 컨테이너 생성

    ```bash
    podman run --name mirror-registry -p 5000:5000 \
    -v /opt/registry/data:/var/lib/registry:z \
    -v /opt/registry/auth:/auth:z \
    -v /opt/registry/certs:/certs:z \
    -e "REGISTRY_AUTH=htpasswd" \
    -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
    -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
    -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
    -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
    -e REGISTRY_COMPATIBILITY_SCHEMA1_ENABLED=true \
    -d 2d4f # <IMAGE ID>
    ```

- 확인

    ```bash
    curl -u <USERNAME:PASSWORD> -k https://<local_registry_host_name>:<local_registry_host_port>/v2/_catalog
    {"repositories":["ocp4/openshift4"]}
    ```
<br></br>

# Yum Repository

### 목적

인터넷이 되지 않는 폐쇄망 내부의 다른 노드들이 Yum Repository를 사용할 수 있도록 한다. Bastion에 Httpd를 통한 File Server를 구축하여 Yum Repository 서비스를 제공한다. 

## 인터넷 환경에서 진행

**1. yum-utils, createrepo 다운로드**
- Repository 동기화에 사용 

    ```bash
    yum -y install yum-utils createrepo
    ```

**2. rpm repository 다운로드 및 repodata 생성**
- repodata : yum repo의 index정보를 담고있는 metadata

    ```bash
    for repo in \
    rhel-7-server-extras-rpms \
    rhel-7-server-ose-4.4-rpms \
    rhel-7-server-rpms
    do
    reposync --repoid=${repo} --download_path=<DOWNLOAD_PATH>
    createrepo -o <DOWNLOAD_PATH> <DOWNLOAD_PATH>
    done 
    ```

**3. 다운받은 rpm과 생성된 repodata 사용 준비** 
- tar로 압축하여 usb로 옮기기

    ```bash
    tar -czvf <FILE_NAME>.tar.gz <DOWNLOAD_PATH>/*
    mount <DISK> <MOUNTPOINT>
    mv <FILE_NAME>.tar.gz <MOUNTPOUINT>
    ```
<br></br>

## Disconnected 환경에서 진행

**1. Host에서 Guest(Bastion)로 tar파일 전송**
- 파일서버로 사용할 httpd서비스의 DocumentRoot 경로 : /var/www/html/repo 

    ```bash
    scp <LOCAL_HDD_MOUNT_POINT>/<FILE_NAME>.tar.gz root@<BASTION'S IP>:/var/www/html/repo
    ```

**2. 압축해제 및 /etc/yum.repo.d/local.repo 수정**
- file:// : yum repository를 위한 httpd서비스를 구축하기 전이므로 file프로토콜을 사용해 bastion 스스로 yum repo사용이 가능하도록 함

    ```bash
    tar -xzvf /var/www/html/repo/<FILE_NAME>.tar.gz
    vi /etc/yum.repo.d/local.repo
    [base]
    name=local repo
    baseurl=file:///var/www/html/repo
    enabled=1
    gpgcheck=0
    ```

**3. httpd 파일서버 구축**
- yum repolist 확인 

    ```bash
    yum repolist
    yum install -y httpd
    ```
- 사용할 포트 수정

    ```bash
    vi /etc/httpd/conf/httpd.conf 
    ...
    Listen 8080
    ...

    systemctl enable --now httpd
    ```

**4. /etc/yum.repo.d/local.repo baseurl 프로토콜 변경**
- 구축한 웹서버의 http 프로토콜을 사용하여 폐쇄망 내의 다른 노드들도 yum 사용 가능하게 함

    ```bash
    vi /etc/yum.repo.d/local.repo
    [base]
    name=local repo
    baseurl=http://localhost/repo
    enabled=1
    gpgcheck=0
    ```

**5. selinux 컨텍스트 설정**
- RHEL7 부터 httpd 프로세스는 httpd_sys_content_t 가 설정된 자원에는 read만 가능 
- read/write 가능한 컨텍스트인 httpd_sys_rw_content_t 컨텍스트를 적용

    ```bash
    chcon -R -t httpd_sys_rw_content_t /var/www/html/repo
    ```

<br></br>

# DNS

### 목적

OCP 클러스터 내의 노드들은 서로의 FQDN을 사용하여 통신한다.  클러스터 내부에서 FQDN기반의 통신이 가능하도록 내부 DNS를 설정한다. 

- cluster domain name : redhat2
- base domain : cccr.local
<br></br>

## 설치 과정 


**1. DNS 서버 설치** 
- bind 를 통해 DNS 서버 설치

    ```bash
    sudo yum install -y bind bind-utils
    ```

**2. DNS 설정 파일 수정** 
- 경로 : /etc/named.conf
- 기본 DNS 설정 파일을 수정하여 실제 사용할 환경에 맞춤
- 사용하지 않는 ipv6를 막고 DNS 쿼리를 허용할 대상을 설정

    ```bash
    vi /etc/named.conf 

    13 listen-on port 53 { any; };       
    14 listen-on-v6 port 53 { none; };     
    21 allow-query     { any; };           
    ```

- 확인

    ```bash
    named-checkconf /etc/named.conf
    ```

**3. 정방향 DNS Zone 설정**
- 정방향 조회 Zone 파일을 /var/named 하위에 설정
- cluster 내 모든 구성요소의 이름과 ip 를 선언
- ocp4에서는 Kubernetes API 요소로 사용되는  api.<cluster_name>, api-int.<cluster_name>와  Route 요소로 사용되는 *.apps.<cluster_name> 을 반드시 선언해야함

    ```bash
    # zone file Example 

    vi /var/named/cccr.local.zone

    $TTL    1H
    @       IN SOA cccr.local. root.cccr.local. (
                            2020090900      ; serial
                            1H              ; refresh
                            15M             ; retry
                            1W              ; expiry
                            15M )           ; minimum
    @   IN NS cccr.local.
        IN A  10.10.10.17
    ns  IN A  10.10.10.17

    ;cluster name
    redhat2   IN CNAME    @

    ; --------------------------------------------------------------------------------------
    ; ---- OCP DNS Records -----------------------------------------------------------------
    ; --------------------------------------------------------------------------------------
    api.redhat2           IN A       10.10.10.17
    api-int.redhat2       IN A       10.10.10.17
    *.apps.redhat2        IN A       10.10.10.17
    bastion.redhat2       IN A       10.10.10.17

    ; --------------------------------------------------------------------------------------
    ; ---- Bootstrap -----------------------------------------------------------------------
    ; --------------------------------------------------------------------------------------
    bootstrap.redhat2      IN A       10.10.10.10

    ; --------------------------------------------------------------------------------------
    ; ---- Master --------------------------------------------------------------------------
    ; --------------------------------------------------------------------------------------
    master-1.redhat2       IN A       10.10.10.11
    master-2.redhat2       IN A       10.10.10.12
    master-3.redhat2       IN A       10.10.10.13

    ; --------------------------------------------------------------------------------------
    ; ---- Service -------------------------------------------------------------------------
    ; --------------------------------------------------------------------------------------
    service-1.redhat2      IN A       10.10.10.18
    service-2.redhat2      IN A       10.10.10.19

    ; --------------------------------------------------------------------------------------
    ; ---- Infra -------------------------------------------------------------------------
    ; --------------------------------------------------------------------------------------
    infra-1.redhat2       IN A       10.10.10.14
    infra-2.redhat2       IN A       10.10.10.15

    ; --------------------------------------------------------------------------------------
    ; ---- Router -------------------------------------------------------------------------
    ; --------------------------------------------------------------------------------------
    router.redhat2        IN A       10.10.10.16

    ; --------------------------------------------------------------------------------------
    ; ---- SCM -------------------------------------------------------------------------
    ; --------------------------------------------------------------------------------------
    scm.redhat2           IN A       10.10.10.20
    ```

**4. 역방향 DNS Zone 설정**
- 역방향 조회 Zone 파일을 /var/named 하위에 설정
- 역방향 DNS를 설정해주지 않으면, 노드들이 자신의 hostname을 찾지못하는 오류가 날 수 있으므로 필요
- ocp4에서는 사용되는 모든 노드들과 api, api-int 를 선언

    ```bash
    vi /var/named/reverse.cccr.local

    $TTL    86400
    @       IN      SOA   cccr.local. ns.cccr.local. (
                          20201005   ; Serial
                          3H         ; Refresh
                          1H         ; Retry
                          1W         ; Expire
                          1H )       ; Minimum

    @      IN NS   cccr.local.
    			 IN A    10.10.10.17

    17     IN PTR  bastion.redhat2.cccr.local.

    10     IN PTR  bootstrap.redhat2.cccr.local.
    11     IN PTR  master-1.redhat2.cccr.local. 
    12     IN PTR  master-2.redhat2.cccr.local.
    13     IN PTR  master-3.redhat2.cccr.local.

    18     IN PTR  service-1.redhat2.cccr.local.
    19     IN PTR  service-2.redhat2.cccr.local.

    14     IN PTR  infra-1.redhat2.cccr.local.
    15     IN PTR  infra-2.redhat2.cccr.local.

    16     IN PTR  router.redhat2.cccr.local.

    20     IN PTR  scm.redhat2.cccr.local.

    17     IN PTR  api.redhat2.cccr.local.
    17     IN PTR  api-int.redhat2.cccr.local.
    ```

**5. DNS Zone 추가**
- DNS zone 파일을 등록하는 설정파일에 앞서 생성한 Zone을 추가

    ```bash
    vi /etc/named.rfc1912.zones

    ...
    zone "cccr.local" IN {
      type master;                  
      file "cccr.local.zone";
      allow-update { none; };
    };

    zone "10.10.10.in-addr.arpa" IN {
            type master;
            file "reverse.cccr.local";
            allow-update { none; };
    };
    ...
    ```

- 확인

    ```bash
    named-checkzone cccr.local /var/named/cccr.local.zone
    named-checkzone cccr.local /var/named/reverse.cccr.local
    ```

**6. DNS 서비스 시작**
- 서비스 시작
    ```bash
    systemctl start named
    systemctl enable named
    ```

- 확인

    ```bash
    nslookup master-1.redhat2.cccr.local
    Server:		10.10.10.17
    Address:	10.10.10.17#53

    Name:	master-1.redhat2.cccr.local
    Address: 10.10.10.11

    dig api-int.redhat2.cccr.local +short
    10.10.10.17

    nslookup 10.10.10.18
    18.10.10.10.in-addr.arpa	name = service-1.redhat2.cccr.local.

    dig -x 10.10.10.11 +short
    master-1.redhat2.cccr.local.
    ```


<br></br>

# CHRONY

### 목적

OCP 클러스터 내 노드들의 시간동기화를 위하여 사용한다. disconnected 환경에서는 인터넷에 접속하여 외부 타임 서버를 사용할 수 없으므로 Bastion 노드를 Chrony Server로 설정하여 로컬 타임으로 시간을 동기화 한다. 

- 시간 기준 : 협정세계시(UTC) 사용
<br></br>

## Chrony Server  ( bastion ) 에서 진행 

**1. Chrony 설치**

```bash
yum -y install chrony
```

**2. Chrony 설정 파일 수정** 
- 로컬에서의 모든 권한을 허용
- 클러스터 내 노드의 ip 대역인 10.10.10.0/24 에게 chrony 서비스를 허용

    ```bash
    vi /etc/chrony.conf

    driftfile /var/lib/chrony/drift
    makestep 1.0 3
    rtcsync
    allow 127.0.0.1
    allow 10.10.10.0/24 
    local stratum 10
    logdir /var/log/chrony
    ```

**3. chrony 서비스 시작** 
- chrony 시작 

    ```bash
    systemctl enable --now chronyd
    systemctl start chronyd 
    ```

- 확인

    ```bash
    timedatectl
    Local time: 수 2020-09-30 01:32:59 UTC
      Universal time: 수 2020-09-30 01:32:59 UTC
            RTC time: 월 2020-10-05 00:53:28
           Time zone: UTC (UTC, +0000)
         NTP enabled: yes
    NTP synchronized: no
     RTC in local TZ: no
          DST active: n/a
    ```
<br></br>
## Chrony Client ( bastion 외 모든 노드 )에서 진행 

**1. Chrony 설치** 

```bash
yum -y install chrony
```

**2. Chrony 설정 파일 수정**
- bastion 노드(10.10.10.17)를 chrony server 로 설정

    ```bash
    vi /etc/chrony.conf

    server 10.10.10.17 iburst
    driftfile /var/lib/chrony/drift
    makestep 1.0 3
    rtcsync
    logdir /var/log/chrony
    ```

**3. chrony 서비스 시작** 
- chrony 서비스 시작 

    ```bash
    systemctl enable --now chronyd
    systemctl start chronyd 
    ```

- 확인

    ```bash
    timedatectl
    Local time: 수 2020-09-30 01:32:59 UTC
      Universal time: 수 2020-09-30 01:32:59 UTC
            RTC time: 월 2020-10-05 00:53:28
           Time zone: UTC (UTC, +0000)
         NTP enabled: yes
    NTP synchronized: no
     RTC in local TZ: no
          DST active: n/a
    ```

<br></br>
# HAPROXY

### 목적

OCP 클러스터 내 노드 간에 통신이 가능하도록 프로토콜을 제공하는 로드밸런서를 생성하기 위해 사용한다.  API 로드밸런서 역할과 클러스터 외부에서 유입되는 트래픽을 라우터로 리다이렉트하는 역할을 수행한다.


- 6443 포트 : Kubernetes API Server
- 22623 포트 : Machine Config Server
- 80 포트 :  HTTP
- 443 포트 :  HTTPS
<br></br>

## 설치 진행 
**1. Haproxy 설치** 

```bash
yum -y install haproxy
```

**2. Haproxy 설정 파일 수정** 
- Kubernetes API Server 포트와 Machine Config Server 포트 에는 부트스트랩과 컨트롤 플레인을 설정. ( 단, 부트스트랩은 마스터 설치가 끝난 후 제거해도 무방 )
- 클러스터 외부에서 유입되는 트래픽은 기본적으로 라우터에서 처리되므로 HTTP, HTTPS 포트에는 라우터 노드를 설정

    ```bash
    # haproxy.cfg file Example 

    vi /etc/haproxy/haproxy.cfg 

    #---------------------------------------------------------------------
    # Global settings
    #---------------------------------------------------------------------
    global
        log         127.0.0.1 local2
        chroot      /var/lib/haproxy
        pidfile     /var/run/haproxy.pid
        maxconn     4000
        user        haproxy
        group       haproxy
        daemon
        stats socket /var/lib/haproxy/stats

    #---------------------------------------------------------------------
    # common defaults that all the 'listen' and 'backend' sections will
    # use if not designated in their block
    #---------------------------------------------------------------------
    defaults
        mode                    tcp
        log                     global
        option                  httplog
        option                  dontlognull
        option http-server-close
        option forwardfor       except 127.0.0.0/8
        option                  redispatch
        retries                 3
        timeout http-request    10s
        timeout queue           1m
        timeout connect         10s
        timeout client          1m
        timeout server          1m
        timeout http-keep-alive 10s
        timeout check           10s
        maxconn                 3000

    #---------------------------------------------------------------------
    # main frontend which proxys to the backends
    #---------------------------------------------------------------------

    frontend api
        bind *:6443
        default_backend controlplaneapi
        option tcplog

    frontend machineconfig
        bind *:22623
        default_backend controlplanemc
        option tcplog

    frontend tlsrouter
        bind *:443
        default_backend secure
        option tcplog

    frontend insecurerouter
        bind *:80
        default_backend insecure
        option tcplog

    #---------------------------------------------------------------------
    # static backend
    #---------------------------------------------------------------------

    backend controlplaneapi
        balance source
        server bootstrap 10.10.10.10:6443 check
        server master-0 10.10.10.11:6443 check
        server master-1 10.10.10.12:6443 check
        server master-2 10.10.10.13:6443 check

    backend controlplanemc
        balance source
        server bootstrap 10.10.10.10:22623 check
        server master-0 10.10.10.11:22623 check
        server master-1 10.10.10.12:22623 check
        server master-2 10.10.10.13:22623 check

    backend secure
        balance source
        server router 10.10.10.16:443 check

    backend insecure
        balance source
        server router 10.10.10.16:80 check
    ```

**3. Haproxy 서비스 시작** 

```bash
setsebool -P haproxy_connect_any 1

systemctl enable haproxy
systemctl start haproxy
```


<br></br>

---
### 참고문헌

[Chapter 3. Installation configuration OpenShift Container Platform 4.5 | Red Hat Customer Portal](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.5/html/installing/installation-configuration#installing-restricted-networks-preparations)

[Creating a mirror registry for a restricted network - Installation configuration | Installing | OpenShift Container Platform 4.4](https://docs.openshift.com/container-platform/4.4/installing/install_config/installing-restricted-networks-preparations.html#installation-mirror-repository_installing-restricted-networks-preparations)
# 3. Openshift Installation

### 목적 

Private registry, Yum repository, DNS, Haproxy, Chrony 등 Openshift 구성요소를 바탕으로 Openshift 설치를 진행한다. 

## 설치 과정 


**1. OCP client와 installer 다운로드** 
- RHCOS 버전과 동이란 버전의 openshift-installer를 설치 
- 본 프로젝트에서 사용하는 RHCOS 4.4.17 버전은 [openshift-v4/clients/ocp/4.4.17](https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.4.17/) 에서 다운


**2. SSH Private Key 생성**

- SSH 프로토콜을 통해 클러스터에 접근 가능 

- SSH key 생성 ( default path: ~/.ssh/)

    ```bash
    ssh-keygen
    # -t : 생성할 key type , -b : 생성할 키의 bit 수, -f : 생성에 사용할 파일 
    ssh-keygen -t rsa -b 4096 -N '' -f ~/.ssh/id_rsa
    ```


**3. 설치 구성 설정**
- install-config.yaml 파일을 사용하여 기본적인 클러스터의 구성 및 구조 설정 

- 작업 디렉토리 생성 및 [install-config.yaml](./src/install-config.yaml) 작성 
    ```bash
    mkdir ~/redhat2_install && cd ~/redhat2_install
    vi install-config.yaml
    ```
    
    - RedHat login 후, [pullSecret](https://cloud.redhat.com/openshift/install/metal/user-provisioned) 다운로드( 24시간 제한 )
    - sshkey ( path : ~/.ssh/id_rsa.pub )


    - additionalTrustBundle에는 Private registry 구축 시 TLS 인증서 만들 때 생성되었던 인증서( ex/ domain.crt )와 동일한 내용을 사용 

    - imageContentSources에는 Private registry 구축 시 저장해두었던 내용을 기입

- install-config.yaml Example

    ```yaml
    apiVersion: v1
    baseDomain: cccr.local
    compute:
    - hyperthreading: Enabled
      name: worker
      replicas: 0
    controlPlane:
      hyperthreading: Enabled
      name: master
      replicas: 3
    metadata:
      name: redhat2
    networking:
      clusterNetworks:
      - cidr: 10.1.0.0/16
        hostPrefix: 24
      networkType: OpenShiftSDN
      serviceNetwork:
      - 172.30.0.0/16
    platform:
      none: {}
    pullSecret: '{"auths":{"bastion.redhat2.cccr.local:5000": {"auth": "ZGV2b3BzOmRrYWdoMS4=","email": "hyukjun1994@gmail.com"}}}'
    sshKey: 'ssh-rsa AAA~~AAA root@bastion.redhat2.cccr.local'
    additionalTrustBundle: |

      -----BEGIN CERTIFICATE-----
      ~~~~
      ~~~~
      ~~~~
      -----END CERTIFICATE-----

    imageContentSources:
      - mirrors:
        - bastion.redhat2.cccr.local:5000/ocp4/openshift4
        source: quay.io/openshift-release-dev/ocp-release
      - mirrors:
        - bastion.redhat2.cccr.local:5000/ocp4/openshift4
        source: quay.io/openshift-release-dev/ocp-v4.0-art-dev
    ```

- install-config.yaml 은 이후 진행과정에서 manifest, ignition 파일을 생성하면서 자동으로 사라지므로 미리 백업을 진행

    ```bash
    cp install-config.yaml install-config.yaml.bak
    ```


**4. Manifest와 ignition 파일 생성**

- Manifest 파일이란, 집합의 일부나 논리정연한 단위인 파일들의 그룹을 위한 메타데이터를 포함하는 파일
- Kubernetes manifests 파일을 install-config.yaml와 같은 디렉토리에 생성
- manifest/[manifest 파일들]의 구조로 생성됨

    ```bash
    ./openshift-install create manifests --dir=~/redhat2_install
    ```

- master에 pod들을 scheduling 하고 싶지 않다면 다음 단계 진행 ( optional )

    ```bash
    cd manifests 
    vi cluster-scheduler-02-config.yml

    masterSchedulable: false # true -> false 
    ```
<br></br>
- Ignition file은 RHCOS에서 초기 구성 중에 디스크를 조작하는 데 사용되는 파일로서, Openshift Container Platform 클러스터 머신의 초기 구성을 수행
- Ignition config file 생성

    ```bash
    ./openshift-install create ignition-configs --dir=~/redhat2/

    tree 
    .
    ├── auth
    │   ├── kubeadmin-password
    │   └── kubeconfig
    ├── bootstrap.ign
    ├── master.ign
    ├── metadata.json
    └── worker.ign
    ```

- 클러스터 내에서 ignition file들을 다운받아 사용할 수있도록 http 파일 서버로 ignition 파일 이동 
- 이 때, 다운 받아 사용 가능하도록 권한을 적절히 설정 

    ```bash
    # bastion에 ignition 파일 들어갈 디렉토리 만들기
    cp dir/*.ign /var/www/html/repo/ign

    chmod 644 /var/www/html/repo/ign/*.ign
    ```


**5. RHCOS 가상 머신 만들기**

- ISO 이미지를 사용하여 bootstrap, master, worker로 사용할 가상머신 생성
- [RedHat mirror server](https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.4/)에서 RHCOS iso와 raw 파일 다운
    - iso 파일 : [rhcos-4.4.17-x86_64-installer.x86_64.iso](https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.4/latest/rhcos-4.4.17-x86_64-installer.x86_64.iso)
    - metal raw 파일 : [rhcos-4.4.17-x86_64-metal.x86_64.raw.gz](https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.4/latest/rhcos-4.4.17-x86_64-metal.x86_64.raw.gz)
- raw 파일은 rhcos 부팅 시 url을 통해 사용되므로 http 서버에 위치

    ```bash
    cd /mnt/test2/rhel-repo # http 서버 파일 위치 
    mkdir raw && cd raw 
    wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.4/4.4.17/rhcos-4.4.17-x86_64-metal.x86_64.raw.gz
    ```

- kvm에 ISO image 기반 RHCOS vm 생성
- VM instance booting
    - booting 화면에서 e or tab을 눌러 kernel command 편집
    - bootstrap, master, worker node에서 동일한 작업 반복
    - 상황에 맞는 install device, ignition 파일, http server의 url, hostname 및 ip 적용 

    ```bash
    # kernel command Example 
    # IMAGE_URL = http://10.10.10.17:8080
    coreos.inst=yes
    coreos.inst.install_dev=sda
    coreos.inst.image_url='IMAGE_URL'/repo/repodata/_____.raw.gz
    coreos.inst.ignition_url='IMAGE_URL'/repo/ign/_____.ign
    ip=10.10.10.XX::10.10.10.1:255.255.255.0:XXXX.redhat2.cccr.local:ens3:none
    nameserver=10.10.10.17
    ```

- 부팅 이후, bastion 에서 SSH 프로토콜을 사용하여 해당 노드로 접근하여 설정 확인
    ```bash
    ssh -i ~/.ssh/id_rsa core@10.10.10.XX
    ```


**6. 클러스터 생성**

- Bootstrap 생성 확인 하다가 완료되었으니 제거해도 좋다는 명령이 나오면 bootstrap 제거 
- 다른 세부 설치 사항 확인하려면 `--log-level`=debug/warn/error 중 선택하여 사용 

    ```bash
    ./openshift-install --dir='INSTALL_DIR' wait-for bootstrap-complete --log-level=info

    INFO Waiting up to 30m0s for the Kubernetes API at https://api.test.example.com...
    INFO API v1.17.1 up
    INFO Waiting up to 30m0s for bootstrapping to complete...
    INFO It is now safe to remove the bootstrap resources
    ```
- 현재 bootstrap이 어떤 일을 하고 있는지 확인 
    ```bash
    journalctl -b -f -u bootkube
    ```


- kubeconfig 파일을 export 해 default system user로 클러스터에 로그인 가능
    - system:admin 계정은 초기 설치 시에만 사용 됨
    - 클러스터 내 모든 node가 Ready가 되어야 완성

    ```bash
    export KUBECONFIG='INSTALL_DIR'/auth/kubeconfig

    oc whoami
    system:admin
    
    oc get nodes
    NAME                          STATUS   ROLES    AGE   VERSION
    master-1.redhat2.cccr.local    Ready    master   7m   v1.16.2
    master-2.redhat2.cccr.local    Ready    master   7m   v1.16.2
    master-3.redhat2.cccr.local    Ready    master   7m   v1.16.2
    worker-1.redhat2.cccr.local    Ready    master   7m   v1.16.2
    worker-2.redhat2.cccr.local    Ready    master   7m   v1.16.2
    ... 
    ```

- 클러스터에 node들 추가 할 때, Pending 상태인 CSR(certificate signing requests)들이 생성됨

    ```bash
    oc get csr
    NAME        AGE     REQUESTOR                                                                   CONDITION
    csr-8b2br   15m     system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Pending 
    csr-8vnps   15m     system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Pending
    csr-bfd72   5m26s   system:node:ip-10-0-50-126.us-east-2.compute.internal                       Pending 
    csr-c57lv   5m26s   system:node:ip-10-0-95-157.us-east-2.compute.internal                       Pending
    ...
    ```

- Pending된 CSR 승인

    ```bash
    oc adm certificate approve `csr_name`
    ```

**7. 클러스터 작업 완료 확인**

- 초기  Operator configuration이 available인지 확인 

    ```bash
    watch -n5 oc get clusteroperators

    NAME                                       VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE
    authentication                             4.4.3     True        False         False      7m56s
    cloud-credential                           4.4.3     True        False         False      31m
    cluster-autoscaler                         4.4.3     True        False         False      16m
    console                                    4.4.3     True        False         False      10m

    ...
    ```

- 클러스터 모니터링 
    - 모니터링 중, 클러스터 완성 후 제공되는 아이디와 비번, console url은 후에 사용되므로 따로 저장
    ```bash
    ./openshift-install --dir=~/redhat2 wait-for install-complete

    INFO Waiting up to 30m0s for the cluster to initialize... 
    INFO Waiting up to 10m0s for the openshift-console route to be created... 
    INFO Install complete! 
    INFO To access the cluster as the system:admin user when using 'oc', run 'export KUBECONFIG=/install/auth/kubeconfig'
    INFO Access the OpenShift web-console here: https://console-openshift-console.apps.redhat2.cccr.local
    INFO Login to the console with user: kubeadmin, password: qMZXS-eoF9S-W46LX-USXoj
    ```

- 클러스터 로그인
    ```bash
    oc login -u kubeadmin -p qMZXS-eoF9S-W46LX-USXoj
    ```
- OCP console에 접근하여 dashboard 확인 ( 위의 아이디와 비번으로 로그인 )



**8. Image registry(Integrated registry) 구축** 

- Bare-metal는 공유 Object storage를 제공하지 않는 플랫폼
- Bare-metal로 클러스터를 구축하는 경우에, Image Registry가 `removed`로 설정되기 때문에 `Managed`로 바꾸어주는 작업이 필요 
    ```bash
    oc edit configs.imageregistry.operator.openshift.io
    
    ...
    spec.managementState: Managed 
    ```



- image-registry는 기본 스토리지를 지정하지 않으면 동작하지 않기 때문에, 설치 후 스토리지 지정 필수( 기본 볼륨 100GB )
- bastion node에 NFS 서버 구성

    ```bash
    vi /etc/exports
    /data *(rw,sync,no_wdelay,root_squash,insecure,fsid=0)

    exportfs -rv
    exporting *:/data
    ```

- image registry configs 파일에 spec.storage.pvc 추가
    - 양식만 넣어 두고 아무 값도 설정하지 않으면 default 로 자동 설정됨

    ```bash
    oc edit configs.imageregistry.operator.openshift.io

    storage : 
      pvc : 
        claim :  
    ```

- PV 생성

    ```bash
    # pv create Example
    vi pv-nfs.yml

    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: pv-nfs
    spec:
      capacity:
        storage: 100Gi
      accessModes:
        - ReadWriteMany
      persistentVolumeReclaimPolicy: Retain
      nfs:
        path: /root/data
        server: 10.10.10.17

    kubectl create -f pv-nfs.yml
    kubectl get persistentvolumes 
    ```

- clusteroperator가 모두 True 인지 확인 

    ```bash
    oc get clusteroperator 

    NAME                                       VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE
    authentication                             4.4.3     True        False         False      7m56s
    cloud-credential                           4.4.3     True        False         False      31m
    cluster-autoscaler                         4.4.3     True        False         False      16m
    console                                    4.4.3     True        False         False      10m
    ...

    ```
<br></br>

---
### 참고문헌
- [ignition Explanation ](https://docs.openshift.com/container-platform/4.4/architecture/architecture-rhcos.html#rhcos-about-ignition_architecture-rhcos)
- [Restricted network bare metal installation - Installing on bare metal | Installing | OpenShift Container Platform 4.4](https://docs.openshift.com/container-platform/4.4/installing/installing_bare_metal/installing-restricted-networks-bare-metal.html)
# 4. Operator

### 목적 

Operator 는 다른 SW 실행 작업의 복잡성을 완화하는 목적으로 만들어진 SW 이다.  Operator는 사용자가 Application을 패키징, 배포 및 관리를 편리하게 할 수 있도록 한다. 본 프로젝트에서는 Operator를 통해 Elasticsearch 와 Cluster Logging Instance 를 설치하고 관리한다. 

- python 3.8.6 설치 필요 (pyyaml, jinja2 라이브러리 포함)
<br></br>

## Operator source 다운로드

**1. Operator Hub 비활성화**
- ocp4에서는 기본적으로 [Operator Hub](https://operatorhub.io/)와 연결되어 클러스터에 사용할 수 있는 operator를 검색 및 사용이 가능하도록 설정되어 있음
- disconnected 환경에서는 내부 저장소를 통해 operator를 사용하므로 기본적으로 설정되어 있는 Operator Hub를 비활성화

    ```bash
    oc patch OperatorHub cluster --type json \
    -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'
    ```

**2. 내부 저장소에 로그인**
- 내부 저장소 생성 시 만들어준 사용자로 registry에 로그인

    ```bash
    podman login -u devops -p dkagh1. 'private registry address -ex) https://bastion.redhat2.cccr.local:5000'
    ```

**3. 실제 mirror 할 operator 목록 작성**
- operator 설치 시 사용할 작업 디렉토리를 생성
- 작업 디렉토리 : ~/operator 
- 카탈로그 안의 모든 operator 를 mirror 하지 않고 필요한 operator 만을 mirror 할 것이므로 사용할 operator를 정의

    ```bash
    mkdir operator && cd operator 

    vi offline-operator-list
    # 다운 받아 올 operator list 작성 
    cluster-logging
    elasticsearch-operator
    ```

**4. 특정 operator만 mirror하는 python 스크립트 실행**
- python 스크립트로 진행
- 사용할 버전에 맞게 --operator-channel 옵션 설정
- [mirror-operator-catalogue.py](./src//mirror-operator-catalogue.py) 참고 

    ```bash
    vi mirror-operator-catalogue.py
    ...
    parser.add_argument(
        "--operator-channel",
        default="4.4",
        help="Operator Channel. Default 4.4")

    ...

    python mirror-operator-catalogue.py --catalog-version 1.0.0 \
    --authfile /opt/registry/pull-secret --registry-olm bastion.redhat2.cccr.local:5000 \
    --registry-catalog bastion.redhat2.cccr.local:5000 --operator-file ./offline-operator-list --icsp-scope=namespace
    ```

**5. image content 소스 정책 정의**
- 현재 작업 디렉토리에 /openshift-disconnected-operators/ publish라는 디렉토리가 생성됨
- 하위의  olm-icsp.yaml 과 rh-catalog-source.yaml 실행

    ```bash
    cd ~/operator/openshift-disconnected-operators/publish

    oc create -f olm-icsp.yaml
    oc create -f rh-catalog-source.yaml
    ```

**6. 생성된 pod 및 catalogsource 확인**
- catalogsource와 packagemanifest 확인 
- namespace는 openshift-marketplace 로 설정됨

    ```bash
    oc get pods -n openshift-marketplace
    NAME                                    READY   STATUS    RESTARTS   AGE
    marketplace-operator-5bc576bff4-vr7cr   1/1     Running   0          4h8m
    redhat-operators-s7ks7                  1/1     Running   0          5d1h

    oc get catalogsource -n openshift-marketplace
    NAME               DISPLAY           TYPE   PUBLISHER   AGE
    redhat-operators   Red Hat Catalog   grpc   Red-Hat     16d

    oc get packagemanifest -n openshift-marketplace
    NAME                     CATALOG           AGE
    elasticsearch-operator   Red Hat Catalog   16d
    cluster-logging          Red Hat Catalog   16d
    ```
<br></br>

## Elasticsearch Operators 설치

**1. 작업 디렉토리 생성**
- 작업 디렉토리 : ~/cluster-logging

    ```bash
    mkdir ~/cluster-logging && cd ~/cluster-logging 
    ```

**2. Elasticsearch Operator의 네임스페이스 작성**
- Elasticsearch namespace : openshift-operators-redhat

    ```bash
    vi ~/cluster-logging/es-namespace.yaml 
    # Example of elasticsearch namespace 
    apiVersion: v1
    kind: Namespace
    metadata:
      name: openshift-operators-redhat
      annotations:
        openshift.io/node-selector: ""
      labels:
        openshift.io/cluster-logging: "true"
        openshift.io/cluster-monitoring: "true"
    ```

- 생성
    ```bash
    oc create -f  ~/cluster-logging/es-namespace.yaml 
    ```

**3. Elasticsearch Operator의 Operator Group 생성**
- Operator Group : openshift-operators-redhat
    ```bash
    vi ~/cluster-logging/es-og.yaml
    # Example of Operator Group 
    apiVersion: operators.coreos.com/v1
    kind: OperatorGroup
    metadata:
      name: openshift-operators-redhat
      namespace: openshift-operators-redhat
    spec: {}
    ```

- 생성

    ```bash
    oc create -f ~/cluster-logging/es-og.yaml
    ```

**4. Elasticsearch Operator Subscription 생성**
- 사용 가능한 채널을 검색해보고, 사용 가능한 채널에 맞춰 Subscription을 생성

    ```bash
    oc get packagemanifest elasticsearch-operator -n openshift-marketplace

    vi ~/cluster-logging/es-sub.yaml
    # Example of subscription 
    apiVersion: operators.coreos.com/v1alpha1
    kind: Subscription
    metadata:
      name: elasticsearch-operator
      namespace: openshift-operators-redhat
    spec:
      channel: "4.4"
      installPlanApproval: "Automatic"
      name: elasticsearch-operator
      source: redhat-operators
      sourceNamespace: openshift-marketplace
    ```

- 생성

    ```bash
    oc create -f ~/cluster-logging/es-sub.yaml
    ```

**5. CSV 생성 확인** 
- CSV = Cluster Service Versions
- Elasticsearch Operator 와 관련된 모든 namespace에 CSV가 생성되었는지 확인

    ```bash
    oc get csv --all-namespaces
    ```

**6. RBAC 생성**
- RBAC = role-based access control ( 역할 기반 접근 제어 )
- Prometheus에게 권한을 부여하기 위해 RBAC를 작성하고 생성

    ```bash
    vi ~/cluster-logging/es-rbac.yaml
    # Example of RBAC
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      name: prometheus-k8s
      namespace: openshift-operators-redhat
    rules:
    - apiGroups:
      - ""
      resources:
      - services
      - endpoints
      - pods
      verbs:
      - get
      - list
      - watch
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: prometheus-k8s
      namespace: openshift-operators-redhat
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: prometheus-k8s
    subjects:
    - kind: ServiceAccount
      name: prometheus-k8s
      namespace: openshift-operators-redhat
    ```

- 생성

    ```bash
    oc create -f ~/cluster-logging/es-rbac.yaml
    ```

**7. Elasticsearch Operator 생성 확인**
- Elasticsearch Operator의 namespace를 통해 elasticsearch-operator 확인 
    ```bash
    oc get pod -n openshift-operators-redhat -o wide
    NAME                                      READY   STATUS    RESTARTS   AGE    IP          NODE                           NOMINATED NODE   READINESS GATES
    elasticsearch-operator-6cb58494cb-sgqb7   1/1     Running   0          5d1h   10.1.4.15   service-2.redhat2.cccr.local   <none>           <none>

    # log 확인 
    oc logs elasticsearch-operator-6cb58494cb-sgqb7 -n openshift-operators-redhat
    oc describe pod/elasticsearch-operator-6cb58494cb-sgqb7 -n openshift-operators-redhat
    ```
<br></br>
## Cluster Logging Operators 설치

**1. Cluster Logging Operator의 namespace 작성**
- Cluster Logging operator namespace : openshift-logging
    ```bash
    vi ~/cluster-logging/clo-namespace.yaml

    apiVersion: v1
    kind: Namespace
    metadata:
      name: openshift-logging
      annotations:
        openshift.io/node-selector: ""
      labels:
        openshift.io/cluster-logging: "true"
        openshift.io/cluster-monitoring: "true"
    ```

- 생성

    ```bash
    oc create -f ~/cluster-logging/clo-namespace.yaml
    ```

**2. Cluster Logging Operator의 Operator Group 생성**
- Operator Group : cluster-logging
    ```bash
    vi ~/cluster-logging/clo-og.yaml

    apiVersion: operators.coreos.com/v1
    kind: OperatorGroup
    metadata:
      name: cluster-logging
      namespace: openshift-logging
    spec:
      targetNamespaces:
      - openshift-logging
    ```

- 생성

    ```bash
    oc create -f ~/cluster-logging/clo-sub.yaml
    ```

**3. cluster-logging Subscription 생성**
- 사용 가능한 채널을 검색해보고, 사용 가능한 채널에 맞춰 Subscription을 생성

    ```bash
    vi ~/cluster-logging/clo-sub.yaml

    apiVersion: operators.coreos.com/v1alpha1
    kind: Subscription
    metadata:
      name: cluster-logging
      namespace: openshift-logging
    spec:
      channel: "4.4"
      name: cluster-logging
      source: redhat-operators
      sourceNamespace: openshift-marketplace
    ```

- 생성

    ```bash
    oc create -f ~/cluster-logging/clo-sub.yaml
    ```

**4. CSV 생성 확인**
- Cluster Logging과 Elasticsearch Operator가 모두 나오는지 확인 

    ```bash
    oc get clusterserviceversions.operators.coreos.com -n openshift-logging

    NAME                                           DISPLAY                  VERSION                 REPLACES   PHASE
    clusterlogging.4.4.0-202009161309.p0           Cluster Logging          4.4.0-202009161309.p0              Succeeded
    elasticsearch-operator.4.4.0-202009161309.p0   Elasticsearch Operator   4.4.0-202009161309.p0              Succeeded
    ```
<br></br>
## Cluster Logging Instance 설치

**1. Cluster Logging Operator Instance 생성**
- Cluster Logging 노드의 수와 Memory, Storage를 유의하여 설정
- nodeSelecor.node-role.kubernetes.io/_____: '' 로 node-selector를 설정하여 원하는 노드에 인스턴스 생성 가능 

    ```bash
    vi ~/cluster-logging/clo-instance.yaml
    # Example of logging operator instance 
    apiVersion: "logging.openshift.io/v1"
    kind: "ClusterLogging"
    metadata:
      name: "instance"
      namespace: "openshift-logging"
    spec:
      managementState: "Managed"
      logStore:
        type: elasticsearch
        elasticsearch:
          resources:
            requests:
              cpu: 500m
              memory: 1Gi
          nodeCount: 1
          nodeSelector:
              node-role.kubernetes.io/infra: ''
          redundancyPolicy: ZeroRedundancy
          storage:
            storageClassName: standard
            size: 10Gi
      visualization:
        type: "kibana"
        kibana:
          replicas: 1
          nodeSelector:
            node-role.kubernetes.io/infra: ''
      curation:
        type: "curator"
        curator:
          schedule: "30 3 * * *"
          nodeSelector:
            node-role.kubernetes.io/infra: ''
      collection:
        logs:
          type: "fluentd"
          fluentd: {}
    ```

- 생성

    ```bash
    oc create -f ~/cluster-logging/clo-instance.yaml
    ```

**2. PV 생성**
- instance 생성 시, 자동으로 PVC가 생성됨
- 생성된 PVC에 연결할 수 있도록 PV 생성.
- PV 정의시 spec.claimRef.name 에 생성된 PVC의 이름 기입

    ```bash
    oc get pvc

    NAME                                         STATUS   VOLUME                  CAPACITY   ACCESS MODES   STORAGECLASS   AGE
    elasticsearch-elasticsearch-cdm-n0ll23ai-1   Bound    elasticsearch-cdm-pv1   10Gi       RWO            standard       3d23h

    vi elasticsearch-pv-1.yaml
    # Example of pv 
    apiVersion: v1
    kind : PersistentVolume
    metadata:
      name : elasticsearch-cdm-pv1
    spec:
      capacity:
        storage: 10Gi
      accessModes:
      - ReadWriteOnce
      nfs:
        path: /pv/logging
        server: 10.10.10.17
      PersistentVolumeReclaimPolicy: Retain
      storageClassName: standard
      claimRef:
        name: elasticsearch-elasticsearch-cdm-n0ll23ai-1
        namespace: openshift-logging
    ```

**3. 생성된 Pods 확인** 
- Operator, Elasticsearch, Kibana, Fluentd pod 가 생성되는 것 확인

    ```bash
    oc get pod -n openshift-logging -o wide
    ```

**4. Kibana에서 로그 확인 및 Dashboard 접속**
- kibana dash board url : kibana-openshift-logging.apps.redhat2.cccr.local
    ```bash
    oc get route -n openshift-logging

    NAME     HOST/PORT                                                  PATH   SERVICES   PORT    TERMINATION          WILDCARD
    kibana   kibana-openshift-logging.apps.redhat2.cccr.local          kibana     <all>   reencrypt/Redirect   None
    ```

- url로 접속하여 Dashboard가 정상적으로 나오는지 확인 
![image](https://user-images.githubusercontent.com/67780144/97552401-8e5d9600-1a17-11eb-8c59-1e85c8261ff1.png)


<br></br>

---
### 참고문헌
https://docs.openshift.com/container-platform/4.4/operators/olm-what-operators-are.html
https://docs.openshift.com/container-platform/4.4/operators/olm-restricted-networks.html
# 5. Quay Install

### 목적 

Quay는 기업 환경을 위한 분산 고가용성 컨테이너 이미지 레지스트리이다. On-Premises, Public Cloud 등 모든 컨테이너 환경 혹은 오케스트레이션 환경에서 작동가능한 것이 장점이다. 
Quay는 git과 통합되어 빌드 자동화 진행, 보안성, 접근 제어, 컨텐츠 분산, 확장가능한 API와 대규모 스케일의 Test 등의 특징을 갖는다. 
본 프로젝트에서는 앞서 구축한 openshift와 함께 CI/CD Pipeline을 구현하기 위해 Quay를 설치한다. 
<br></br>

## 전체 Architecture

**1. 논리적 Architecture**
<br></br>

![image](https://user-images.githubusercontent.com/67780144/97552288-6a01b980-1a17-11eb-963b-f95ce6733aa5.png)


- Quay는 Openshift Container Platform의 외부 Node로써 구현
- Quay가 외부 Source Registry로부터 Image를 받아와 Mirroring한 뒤에 Clair을 통해 CVE Metadata를 Fetch하고 Image 취약점을 검사
- 본 프로젝트에서는 전체 리소스를 고려하여 Quay를 1중화로 진행

**2. 물리적 Architecture(Quay Node 내부 컨테이너들간의 관계)**

![image](https://user-images.githubusercontent.com/67780144/97552329-77b73f00-1a17-11eb-9d17-9628e484a394.png)

- `Quay` : Container Registry로서 Quay Container를 Pod의 여러 구성 요소로 구성된 서비스로 실행
- `Database(Mysql)` : Quay에서 기본 Metadata Storage로 사용
- `Redis(Key, Value Store)` : Live Builder Log 및 Red Hat Quay turorial 저장
- `Clair` : 컨테이너 이미지의 취약점을 검사하고 수정 사항을 제안
- `gitLab` : 형상 관리 도구
- `Object Storage` : 오브젝트 형태의 데이터를 저장할 수 있는 스토리지로 본 프로젝트는 On-premises 환경이므로 Minio 사용 

<br></br>

## Quay 설치 준비 

**설치 환경**
- quay : 3.2.1 v
- quay-builder : 3.2.1 v
- clair-jwt : 3.2.1 v
- External IP : 192.168.100.10/24 (NAT)
- Internal IP : 10.10.10.21
- 방화벽 해제 

**Quay의 Port Forwarding**
- QuayBuilder : 80 Port
- Redis : 6379 Port
- MySQL : 3306 Port
- QuayConfig : 28443 Port
- Minio : 9000 Port
- Gitlab : 18443, 18080, 18022 Port

**Clair의 Port Forwarding**
- JWTproxy : 6060 Port
- pgsql : 5432 Port
- Postgresql : pgsql과 Link 연결

<br></br>

**1. Quay 설치 사전 준비**
- Quay로 사용할 RHEL 7.8 OS의 가상머신을 생성한 뒤, 아래 과정 진행 
- RAM : 8 GB , vCPU : 3 Core , Disk : 60 GB
- hostname 설정

    ```bash
    # Quay Node의 Hostname 변경
    hostnamectl set-hostname quay.redhat2.cccr.local

    # Quay Node와 Host PC에 각각 ip 추가
    # 해당 IP로 웹 콘솔 접근 가능 
    vi /etc/hosts
    192.168.100.10	quay.redhat2.cccr.local
    192.168.100.10	clair.redhat2.cccr.local
    192.168.100.10	gitlab.redhat2.cccr.local
    ```

- RHEL OS 사용을 위해 Redhat 계정으로 Subscription을 등록 
- Subscription 등록 과정에서 Repository 활성화
    ```bash
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release

    subscription-manager register # RedHat 계정 입력 
    Username: ${USERNAME}
    Password: ${PASSWORD}

    The system has been registered with ID: ~~~~
    The registered system name is: quay.redhat2.cccr.local

    subscription-manager list --available --matches '*RHEL*'
    subscription-manager attach --pool=<<Pool_ID>>
    subscription-manager repos --disable="*"
    subscription-manager repos --enable="rhel-7-server-rpms" --enable="rhel-7-server-extras-rpms"

    yum update -y
    # 업데이트 후, Server Reboot 
    reboot
    ```

**2. Docker 설치**

- Docker 설치

    ```bash
    yum install docker device-mapper-libs device-mapper-event-libs**
    systemctl enable docker
    systemctl start docker
    systemctl is-active docker
    ```

- Insecure Docker Registry 세팅

    ```bash
    vi /etc/sysconfig/docker
    ...
    # 내용 추가 
    ADD_REGISTRY=--add-registry '<<quay FQDN>>'
    INSECURE_REGISTRY=--insecure-registry '<<quay FQDN>>'
    ```

**3. Quay 인증**
- [quay.io](http://quay.io)에서 Red Hat Quay V3 Container Image을 얻기 위하여 Key를 통해 인증

    ```bash
    [root@quay ~]docker login -u="<<ID>>" -p="<<PASSWORD>>" quay.io
    ```

<br></br>
## Quay 설치 과정 

**1. Database**

- Database 설치 디렉터리 생성 
    ```bash
    mkdir -p /var/lib/mysql
    chmod -R 777 /var/lib/mysql
    ```
- 환경변수 설정
    ```bash
    export MYSQL_CONTAINER_NAME=mysql
    export MYSQL_DATABASE=quay
    export MYSQL_PASSWORD=quay
    export MYSQL_USER=quay
    export MYSQL_ROOT_PASSWORD=quay
    ```
- Quay의 Database는 PostgreSQL나 MySQL 모두 사용 가능
- 본 프로젝트에서는 MySQL을 설치 
    ```bash
    docker run --detach --restart=always \
    --env MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
    --env MYSQL_USER=${MYSQL_USER} \
    --env MYSQL_PASSWORD=${MYSQL_PASSWORD} \
    --env MYSQL_DATABASE=${MYSQL_DATABASE} \
    --name ${MYSQL_CONTAINER_NAME} \
    --publish 3306:3306 -v /var/lib/mysql:/var/lib/mysql/data:Z \
    registry.access.redhat.com/rhscl/mysql-57-rhel7
    ```

- mysql 접근 가능한지 확인 

    ```bash
    yum install -y mariadb

    mysql -h 192.168.100.10 -u root --password=quay

    Welcome to the MariaDB monitor.
    Commands end with ; or \g.
    Your MySQL connection id is 2
    Server version: 5.7.24 MySQL Community Server (GPL)
    Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.
    Type 'help;' or '\h' for help. Type '\c' to clear the current input
    statement.
    MySQL [(none)]> \q
    Bye
    ```

**2. Redis**

- Redis 설치 디렉토리 생성 
    ```bash
    mkdir -p /var/lib/redis
    chmod -R 777 /var/lib/redis
    ```
- Redis 설치 
    ```bash
    docker run -d --restart=always -p 6379:6379 \
    --privileged=true -v /var/lib/redis:/var/lib/redis/data:Z \
    registry.access.redhat.com/rhscl/redis-32-rhel7
    ```

- Redis와 통신 가능한지 확인
    ```bash
    yum install telnet -y

    telnet 192.168.100.10 6379

    [root@quay ~]# telnet 192.168.100.10 6379
    ..
    ..
    Escape character is '^]'.
    MONITOR
    +OK
    QUIT
    +OK
    Connection closed by foreign host.
    ```

**3. Gitlab**

- Gitlab 설치 디렉토리 생성 및 권한 설정 
    ```bash
    # config, logs, data
    mkdir -p /srv/gitlab/{config,logs,data}
    chmod -R 777 /srv/gitlab
    chown 1000:1000 /srv/gitlab

    cd srv
    chcon -Rv -u system_u *
    chcon -Rv -t container_file_t *

    ls -lZ *
    drwxrwxr-x. root root system_u:object_r:container_file_t:s0 config
    drwxr-xr-x. root root system_u:object_r:container_file_t:s0 data
    drwxr-xr-x. root root system_u:object_r:container_file_t:s0 logs

    ```

- Gitlab 설치 

    ```bash
    docker run --detach --hostname gitlab.redhat2.cccr.local \
    --publish 18443:443 --publish 18080:80 --publish 18022:22 \
    --name gitlab --restart always \
    --volume /srv/gitlab/config:/etc/gitlab \
    --volume /srv/gitlab/logs:/var/log/gitlab \
    --volume /srv/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce:latest
    ```

**4. Minio**
- Minio 설치 디렉터리 생성 
    ```bash
    mkdir /mnt/minio
    chmod -R 777 /mnt/minio
    ```

- Minio 설치
    ```bash
    docker run -itd -p 9000:9000 \
    --name minio1 --privileged=true \
    -e "MINIO_ACCESS_KEY=minioadmin" \
    -e "MINIO_SECRET_KEY=minioadmin" \
    -v /mnt/minio:/data minio/minio server /data
    ```
- Minio dash-board 접속 후, quay 전용 디렉터리 생성


**5. quayconfig 기반 Red Hat Quay 설정**

- 사전에 다른 Quay 컨테이너를 사용하여 사용할 Quay 구성 파일(config.yaml)과 인증파일(security_scanner.pem) 생성
- Quay가 어떤 Redis, MySQL, Gitlab, Clair와 연동할 것인지, Quay Web Console 접속할 시 사용할 ID, Password 등에 대해 정의

- 구성파일 생성용 Quay 컨테이너 생성
    ```bash
    docker run --privileged=true -p 28443:8443 -d quay.io/redhat/quay:v3.2.1 config password
    ```
- Docker process가 ipv4의 ip를 갖도록 설정 (optional)
    ```bash
    vi /etc/sysctl.conf 
    net.ipv4.ip_forward = 1

    systemctl restart network
    ```

- quay 구성 도구가 실행중인 컨테이너의 URL(ex-https://quay.redhat2.cccr.local:28443/) 접속하여 새로운 quayconfig 생성 

**6. quayconfig 생성 ( Dashboard에서 진행 )**

- Setup (DB 정보 입력)
    - Database Type : MySQL
    - Database Server : 192.168.100.10:3306
    - Username : quay 
    - Password : quay 
    - Database Name : quay 

- Super User 생성
    - Username: admin 
    - Email address : ______@gmail.com
    - Password : xxxxxx 

- Server Configuration
    - Server Hostname : quay.redhat2.cccr.local 

- Time Machine
    - 따로 설정하지 않음 

- Redis
    - Redis Hostname : 192.168.100.10
    - Redis Port : 6379

- Repository Mirroring
    - Enable Repository Mirroring 선택 

- Security Scanner
    - Enable Security Scanning 선택
    - Security Scanner Endpoint : http://clair.redhat2.cccr.local:6060 ( clair container의 endpoint 기입 )

    - Authentication Key 다운로드
        - Assign New Key 
        - key name : security_scanner Service Key
        - 다운로드 한 키는 Clair 컨테이너의  /var/lib/clair-config에 복사

- Application Registry
    - Enable App Registry 선택 

- Registry Protocol Settings
    - Restrict V1 Push Support 선택 해제 

- Minio 설정
    - Storage Engine : Red Hat Openshift Container Storage (NooBaa S3)
    - NooBaa Server Hostname : 192.168.100.10
    - Custom Port(optional) : 9000
    - Access Key : minioadmin
    - Secret Key : minioadmin
    - Bucket Name : quay 
    - Storage Directory : /registry 

- Gitlab
    - Application ID와 Secret이 필요하므로 Gitlab 웹 콘솔(http://gitlab.redhat2.cccr.local)에 접속 후 로그인 
    - Settings → Application → 생성 
        - Name : testapp
        - Redirect URI : [http://gitalb.redhat2.cccr.local/testapp](http://gitalb.redhat2.cccr.local/testapp) (테스트용으로 지정)

    - 생성된 Application의 App ID와 Secret을 준비 
    - Enable Gitlab Trigger을 체크하고 Endpoint, App ID, Secret 기입

![image](https://user-images.githubusercontent.com/67780144/97552755-0035df80-1a18-11eb-813d-9df2ed190453.png)


- 다음 단계로 넘어가 설정 정보가 포함된 File을 local에 다운로드 


**7. Quay 설치 및 배포**

- 앞서 만든 minio, quay (설정 컨테이너), gitlab, redis, mysql 컨테이너 확인

    ```bash
    docker ps

    CONTAINER ID        IMAGE                                             COMMAND                  CREATED             STATUS                    PORTS                                                                  NAMES
    4720d202d0e3        minio/minio                                       "/usr/bin/docker-e..."   18 minutes ago      Up 18 minutes             0.0.0.0:9000->9000/tcp                                                 minio1
    2575c3050175        quay.io/redhat/quay:v3.2.1                        "/quay-registry/qu..."   31 minutes ago      Up 31 minutes             7443/tcp, 8080/tcp, 0.0.0.0:28443->8443/tcp                            kind_pare
    7a33ff0ce108        gitlab/gitlab-ce:latest                           "/assets/wrapper"        37 minutes ago      Up 37 minutes (healthy)   0.0.0.0:18022->22/tcp, 0.0.0.0:18080->80/tcp, 0.0.0.0:18443->443/tcp   gitlab
    626c3eb9fd77        registry.access.redhat.com/rhscl/redis-32-rhel7   "container-entrypo..."   44 minutes ago      Up 44 minutes             0.0.0.0:6379->6379/tcp                                                 stupefied_dubinsky
    5905964d5a75        registry.access.redhat.com/rhscl/mysql-57-rhel7   "container-entrypo..."   46 minutes ago      Up 46 minutes             0.0.0.0:3306->3306/tcp                                                 mysql
    ```


- Quay에서 사용할 디렉토리를 생성
    ```bash
    mkdir -p /mnt/quay/{config, storage}
    ```
- Quay 설정파일 옮기기
- 앞서 local PC에 다운 받은 quay-config.tar.gz를 Quay vm 으로 이동 
    ```bash
    scp quay-config.tar.gz root@192.168.100.10:/mnt/quay/config/
    ```
- Quay vm 에서 quay-config.tar.gz 압축 해제 
    ```bash 
    cd /mnt/quay/config

    tar xvf quay-config.tar.gz

    chcon -Rv -u system_u *.yaml
    chcon -Rv -t container_file_t *
    ```

- Quay 설치 및 배포
- 이 때, 컨테이너에 gitlab host 정보를 추가하여 builderworker가 quay와 같은 서버에 설치될 경우에 발생할 수 있는 no_such_host 에러를 방지 
    ```bash
    docker run --restart=always -p 443:8443 -p 80:8080 \
    --add-host gitlab.redhat2.cccr.local:192.168.100.10 \
    --sysctl net.core.somaxconn=4096 \
    --privileged=true \
    -v /mnt/quay/config:/conf/stack:Z \
    -v /mnt/quay/storage:/datastorage:Z \
    -d quay.io/redhat/quay:v3.2.1
    ```

- Quay Super User 계정 ( ID: admin, Password: password )으로 Quay 콘솔(quay.redhat2.cccr.local)에 로그인하여 확인 
![image](https://user-images.githubusercontent.com/67780144/97552713-f318f080-1a17-11eb-82eb-d1de430f1b29.png)


**8. Mirror Worker와 Builder 실행**
- Mirror worker 실행

    ```bash
    docker run -d --name mirroring-worker -v /mnt/quay/config:/conf/stack:Z \
    -d quay.io/redhat/quay:v3.2.1 repomirror
    ```

- Builder 실행
- 환경 변수로 SERVER를 사용하여 worker가 Red Hat Quay에 접근할 수 있는 Host이름을 지정해야 하며, TLS를 사용하지 않는 경우 ws 파라미터와 함께 Port를 명시해야 함

    ```bash
    docker run --restart on-failure \
    -e SERVER=ws://192.168.100.10:80 \
    --privileged=true \
    -v /var/run/docker.sock:/var/run/docker.sock:Z \
    -d quay.io/redhat/quay-builder:v3.2.1
    ```
<br></br>

## Clair 설치

- Openshift에서 Clair는 컨테이너 이미지를 스캔하여 취약점을 검사하고 수정 사항을 제안하는 역할을 수행 
- Clair를 실행하려면 Database가 필요
- Clair의 Database로 MySQL은 지원하지 않으므로 본 프로젝트에서는 PostgreSQL로 구성 

**1. Clair 설치 작업 디렉터리 생성**
- 작업 디렉터리 : /var/lib/clair-config
    ```bash
    mkdir -p /var/lib/clair-config && cd /var/lib/clair-config
    chmod 777 /var/lib/clair-config
    ```

**2. PostgreSQL 설치**
- pgsql Container
    ```bash
    docker run -d -p 5432:5432 --name pgsql -e POSTGRES_PASSWORD=mysecretpassword \
    -e POSTGRES_HOST_AUTH_METHOD=trust postgres
    ```

- postgres Container
    ```bash
    docker run --rm --link pgsql:postgres postgres \
    sh -c 'echo "create database clairtest" | psql -h \
    "$POSTGRES_PORT_5432_TCP_ADDR" -p \
    "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'
    ```

**3. Clair Image Pull ( Security-enabled )**

- Clair 설정 파일( [config.yaml](./src/clair_config.yaml) )생성

    ```bash
    vi /var/lib/clair-config/config.yaml
    # Example of clair config.yaml 
    clair:
    database:
        type: pgsql
        options:
        source: postgresql://postgres@192.168.100.10:5432/clairtest? sslmode=disable
        cachesize: 16384
    api:
        healthport: 6061
        port: 6062
        timeout: 900s
        paginationkey:
    updater:
        interval: 6h
        enabledupdaters:
        - debian
        - ubuntu
        - rhel
        - oracle
        - alpine
        - suse
        notifier:
        attempts: 3
        renotifyinterval: 1h
        http:
            endpoint: http://quay.redhat2.cccr.local/secscan/notify
            proxy: http://localhost:6063
    jwtproxy:
    signer_proxy:
    enabled: true
    listen_addr: :6063
    ca_key_file: /certificates/mitm.key  
    ca_crt_file: /certificates/mitm.crt  
    signer:
        issuer: security_scanner
        expiration_time: 5m
        max_skew: 1m
        nonce_length: 32
        private_key:
        type: autogenerated
        options:
            rotate_every: 12h
            key_folder: /clair/config/
            key_server:
            type: keyregistry
            options:
                registry: http://quay.redhat2.cccr.local/keys/
    verifier_proxies:
    - enabled: true
        listen_addr: :6060
        verifier:
        audience: http://clair.redhat2.cccr.local:6060
        upstream: http://localhost:6062
        key_server:
            type: keyregistry
            options:
            registry: http://quay.redhat2.cccr.local/keys/
    ```

- local에서 Quay vm의 /var/lib/clair-config 로 security_scanner.pem 파일 이동
- Clair 관련 파일 권한 설정
    ```bash
    # config.yaml
    chcon -Rv -u system_u *.yaml
    # security_scanner.pem
    chcon -Rv -u system_u *.pem
    # Context Change
    chcon -Rv -t container_file_t *
    ```
**4. Clair 컨테이너 설치 및 배포**
- jwt(Json Web Token) : Json 포맷을 이용하여 사용자에 대한 속성을 저장하는 Claim 기반의 Web Token

    ```bash
    docker run -d --restart=always -p 6060:6060 -p 6061:6061 \
    --add-host quay.redhat2.cccr.local:192.168.100.10 \
    --privileged=true -v /var/lib/clair-config:/clair/config \
    quay.io/redhat/clair-jwt:v3.2.1
    ```
<br></br>

## Quay 웹 콘솔에서 Docker Build Test
**1. Quay 로 Docker 이미지 pull**
- Quay Domain Name : quay.redhat2.cccr.local
- ubi7 이라는 Docker 이미지를 사용하여 test 진행 
- 아래 명령어 실행 시, Quay 에서 repositories에서 /admin/ubi7 확인 가능
    ```bash
    docker pull ubi7

    # Namespace : admin, Repository : ubi7, Version : v0.1
    docker tag ubi7 quay.redhat2.cccr.local/admin/ubi7:v0.1
    docker push quay.redhat2.cccr.local/admin/ubi7:v0.1
    ```

**2. 레포지토리에 Robot 계정 생성**
- Quay 콘솔을 통해 Repositories-> /admin/ubi7-> Setting-> Robot 계정 생성
- Robot에게 ubi7 Repository에 대한 Read 권한 부여
![image](https://user-images.githubusercontent.com/67780144/97552836-16dc3680-1a18-11eb-9552-0a361a4bd346.png)

**3. Docker 이미지 Build**
- Dockerfile 준비
    ```bash
    ### Dockerfile

    FROM quay.redhat2.cccr.local/admin/ubi7:v0.1
    RUN echo "Hello world" > /tmp/hello_world.txt
    CMD ["cat", "/tmp/hello_world.txt"\
    ```

- Repository-> Build Triggers -> Start New Build -> Select file -> Dockerfile 에 앞서 만든 Dockerfile 선택 -> Start Build 

- DockerBuild 성공
![image](https://user-images.githubusercontent.com/67780144/97552883-2196cb80-1a18-11eb-9fd1-73cc6b55683c.png)

**4. 이미지 보안성 검사**
- DockerBUild 성공 화면에서 설정(톱니바퀴)에서 Tag 이름을 v0.2로 수정
- Tag History 확인 및 빌드된 이미지의 보안성 체크 확인
![image](https://user-images.githubusercontent.com/67780144/97552930-2c516080-1a18-11eb-82e3-2079b57cc31b.png)

- tag 수정한 Docker 컨테이너가 잘 작동하는지 확인  

    ```bash
    docker run -it quay.redhat2.cccr.local/admin/ubi7:v0.2
    Hello world

    docker ps -a
    CONTAINER ID        IMAGE                                             COMMAND                  CREATED             STATUS                     PORTS                                                                  NAMES
    268c03123b2a        quay.redhat2.cccr.local/admin/ubi7:v0.2           "cat /tmp/hello_wo..."   2 minutes ago       Exited (0) 2 minutes ago                                                                          infallible_wozniak
    ```
    <br></br>

## Openshift 내부 Registry에서 Quay Build Test

**1. Quay DNS 설정**
- bastion 노드를 Quay 의 DNS 서버로 설정하여 Disconnected 환경의 OCP Node와 통신이 가능하도록 설정
    ```bash
    vi /etc/resolv.conf 

    server 10.10.10.17
    server 8.8.8.8
    ```

**2. Quay 노드에서 oc 명령어 활성화**
- Bastion node 에서 활성화 했던 것과 동일한 방법으로 진행
- 단, Quay 노드는 인터넷이 되는 환경에서 사용되므로 oc command를 바로 다운 가능
- 명령으로 사용가능 하도록 환경변수 설정 경로 하위에 oc와 kubectl 기입 

    ```bash
    wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.4.17/openshift-client-linux-4.4.17.tar.gz

    tar -xvf openshift-client-linux-4.4.17.tar.gz 
    README.md
    oc
    kubectl

    cp ./oc /usr/local/bin/
    cp ./kubectl /usr/local/bin/

    oc version
    Client Version: 4.4.17
    Server Version: 4.4.17
    Kubernetes Version: v1.17.1+20ba474

    kubectl version
    Client Version: version.Info{Major:"1", Minor:"17", GitVersion:"v1.17.0-4-g38212b5", GitCommit:"d89e458c3dff553f9a732b282830bfa9b4e0ab9b", GitTreeState:"clean", BuildDate:"2020-08-10T08:45:51Z", GoVersion:"go1.13.4", Compiler:"gc", Platform:"linux/amd64"}
    Server Version: version.Info{Major:"1", Minor:"17+", GitVersion:"v1.17.1+20ba474", GitCommit:"20ba474", GitTreeState:"clean", BuildDate:"2020-08-10T09:03:30Z", GoVersion:"go1.13.4", Compiler:"gc", Platform:"linux/amd64"}

    # /root 디렉터리에 kubeconfig 파일 위치하기 
    export KUBECONFIG=/root/kubeconfig

    # 이제 oc 명령어를 사용할 수 있음
    oc whoami
    kube:admin

    oc get nodes
    NAME                           STATUS     ROLES    AGE   VERSION
    master-1.redhat2.cccr.local    Ready      master   25d   v1.17.1+20ba474
    master-2.redhat2.cccr.local    Ready      master   25d   v1.17.1+20ba474
    ...
    ```
    <br></br>

## Allowing Pods to reference images from other secured registries

**1. ~/.docker/config.json 확인**
- Docker clients용 .dockercfg ( $HOME/.docker/config.json )은 이전에 보안 또는 안전하지 않은 레지스트리에 로그인 한 경우 인증 정보를 저장하는 Docker credentials 파일
- OCP의 내부 레지스트리가 아닌 보안 컨테이너 이미지를 가져오려면 Docker Credentials에서 pull secret을 생성하여 서비스 계정에 추가해야 함

    ```bash
    cd .docker/
    cat config.json 
    {
        "auths": {
            "quay.io": {
                "auth": "cmVkaGF0K3F1YXk6TzgxV1NIUlNKUjE0VUFaQks1NEdRSEpTMFAxVjRDTFdBSlYxWDJDNFNEN0tPNTlDUTlOM1JFMTI2MTJYVTFIUg=="
            },
            "quay.redhat2.cccr.local": {
                "auth": "YWRtaW46cGFzc3dvcmQ="
            }
        }
    }
    ```
**2. secret와 link 생성**
- secret 생성
    ```bash 
    oc create secret generic 'secret 이름' \
    --from-file=.dockerconfigjson=/root/.docker/config.json --type=kubernetes.io/dockerconfigjson

    secret/test created

- secret link 설정 
    ```bash
    # default : 기본 서비스 계정
    oc secrets link default 'secret 이름' --for=pull
    # build 이미지를 push & pull 하는데 secret을 사용하려면 Pod 내부에 Secret을 마운트 하여 사용
    oc secrets link builder 'secret 이름'
    ```

**3. cluster yaml 파일 수정**
- OCP 콘솔 -> Search -> Image (Config) -> Cluster -> YAML 에 아래 내용 기입

    ```bash
    # Exmaple
    allowedRegistriesForImport:
    	- domainName: quay.redhat2.cccr.local
    		insecure: true
    registrySources:
    	insecureRegistries:
    	- quay.redhat2.cccr.local
    ```
<br></br>

---
### 참고문헌
https://coreos.com/quay-enterprise/docs/latest/clair.html
# CI/CD

### 목적

Integration Hell을 극복하기 위한 파이프라인을 구성하는 Continuous Integration / Continuous Deployment 프로그램인 Jenkins, 소스 코드를 검사하기 위한 프로그램인 SonarQube, 빌드 및 외부 레지스트리 역할을 담당하는 Nexus 설치를 진행한다. 또한, 파이프라인을 구성하기 위한 Jenkinsfile을 작성해서 Build Pipeline을 구성한다.

## 설치 과정

## 1. Prepare Images for CI/CD

- 이미지 준비
    - `get-image.sh` 생성
    - jenkins-slave-skopeo-centos7은 skopeo를 이용하기 위해서, local git repo에서 받으면 됨

    ```bash
    #!/bin/bash

    echo "set variable"
    export RH_ID='REDHAT_ID'
    export RH_PW='REDHAT_PASSWORD'

    echo "login external registry"
    podman login -u ${RH_ID} -p ${RH_PW} registry.redhat.io
    sleep 2

    echo "pull images"
    podman pull registry.redhat.io/openshift4/ose-jenkins:v4.4
    podman pull registry.redhat.io/openshift4/ose-jenkins-agent-maven:v4.2
    podman pull registry.redhat.io/openshift4/jenkins-slave-skopeo-centos7:latest
    podman pull registry.redhat.io/jboss-eap-7/eap72-openshift:1.2
    podman pull registry.redhat.io/rhscl/postgresql-96-rhel7:latest
    podman pull docker.io/openshiftdemos/gogs:0.11.34
    podman pull docker.io/siamaksade/sonarqube:latest

    echo "save images"
    podman save -o cicd.tar \
      registry.redhat.io/openshift4/ose-jenkins:v4.4 \
      registry.redhat.io/openshift4/ose-jenkins-agent-maven:v4.2 \
      registry.redhat.io/openshift4/jenkins-slave-skopeo-centos7:latest
      registry.redhat.io/jboss-eap-7/eap72-openshift:1.2 \
      registry.redhat.io/rhscl/postgresql-96-rhel7:latest \
      docker.io/openshiftdemos/gogs:0.11.34 \
      docker.io/siamaksade/sonarqube:latest
    ```

    - `get-image.sh` 실행

    ```bash
    sh get-image.sh
    ```

### 2. Private Registry에 이미지 push

- `push-image.sh` 생성

    ```bash
    cat <<EOF > push-image.sh
    #!/bin/bash

    # set variable
    export PRV_ID='admin'
    export PRV_PW='admin'
    export PRV_REG='registry.demo.ocp4.com:5000'

    echo "=== SET VARIABLE ============================================"
    echo PRIVATE_REG=${PRV_REG}
    echo "============================================================="

    # load images
    podman load -i cicd.tar # Dont do this

    export PRAVATE_REG='bastion.redhat2.cccr.local:5000'
    # tag images
    podman tag registry.redhat.io/openshift4/ose-jenkins:v4.4 ${PRAVATE_REG}/openshift4/ose-jenkins:v4.4
    podman tag registry.redhat.io/openshift4/ose-jenkins-agent-maven:v4.2 ${PRAVATE_REG}/openshift4/ose-jenkins-agent-maven:v4.2
    podman tag registry.redhat.io/rhscl/postgresql-96-rhel7:latest ${PRAVATE_REG}/rhscl/postgresql-96-rhel7:latest
    podman tag docker.io/openshiftdemos/gogs:0.11.34 ${PRAVATE_REG}/openshiftdemos/gogs:0.11.34
    podman tag registry.redhat.io/jboss-eap-7/eap72-openshift:1.2 ${PRAVATE_REG}/jboss-eap-7/eap72-openshift:1.2
    podman tag docker.io/siamaksade/sonarqube:latest ${PRAVATE_REG}/siamaksade/sonarqube:latest

    # login private registry
    podman login -u ${PRV_ID} -p ${PRV_PW} ${PRV_REG}

    # push images
    podman push ${PRAVATE_REG}/openshift4/ose-jenkins:v4.4
    podman push ${PRAVATE_REG}/openshift4/ose-jenkins-agent-maven:v4.2
    podman push ${PRAVATE_REG}/rhscl/postgresql-96-rhel7:latest
    podman push ${PRAVATE_REG}/openshiftdemos/gogs:0.11.34
    podman push ${PRAVATE_REG}/jboss-eap-7/eap72-openshift:1.2
    podman push ${PRAVATE_REG}/siamaksade/sonarqube:latest

    EOF

    ```

    - `push-image.sh` 실행

    ```bash
    sh push-image.sh
    ```

## Register certificate for mirror regitstry

### 1. Mirror Registry의 access를 위한 추가 trust stores 생성

> 해당 작업을 위해서는 cluster-admin 권한이 필요하다.

- mirror registry의 trust ca 등록을 위한 `configmap` 파일 생성

    ```bash
    cat <<EOF > mirror-registry-ca.yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: mirror-registry-ca
      namespace: openshift-config
    data:
      registry.demo.ocp4.com..5000: |
        # mirror registry의 인증서
        -----BEGIN CERTIFICATE-----
        ... 
        -----END CERTIFICATE-----
    EOF

    ```

    - mirror registry의 인증서의 기본 위치는 opt/registry/certs
    - cluster admin 권한으로 OCP 로그인 후 `openshift-config` project

    ```bash
    oc login -u <cluster-admin id> -p <cluster-admin pw>
    oc create -f mirror-registry-ca.yaml -n openshift-config
    ```

### 2. 추가된 mirror registry의 trust CA 등록

- oc edit으로 이미지 yaml 파일 변경

    ```bash
    oc edit image.config.openshift.io cluster
    ```

    ```bash
    (...)
    spec:
      additionalTrustedCA:
        name: mirror-registry-ca
    (...)

    ```

## Prepare ci/cd tools

### 1. create projecs for ci/cd

- project 생성
    - project 정보는 dev-demo(개발), stage-demo(스테이지), cicd-demo(CI/CD tools)이 준비된다.
    - label node를 넣어주는 이유는, 만든 application이 dev, stage에 뜨지만, 노드를 service에 띄워주기 위함이다.
        - 부하를 분산시켜주기 위한 목적이다.

    ```bash
    oc login -u <ocp id> -p <ocp pw>

    oc label node service-1.redhat2.cccr.local cicd=true
    oc label node service-1.redhat2.cccr.local service=true

    oc label node service-2.redhat2.cccr.local cicd=true
    oc label node service-2.redhat2.cccr.local service=true

    oc new-project dev-demo   --display-name="test - Dev"
    oc new-project stage-demo --display-name="test - Stage"
    oc new-project cicd-demo  --display-name="CI/CD"
    ```

    - cicd project에서 dev 및 stage에 빌드 및 배포를 수행할 수 있도록 권한 설정

    ```
    oc policy add-role-to-group edit system:serviceaccounts:cicd-demo -n dev-demo
    oc policy add-role-to-group edit system:serviceaccounts:cicd-demo -n stage-demo
    ```

### 2. config builder secret link

- mirror-registry, quay에 접근하기 위한 secret을 생성 및 정의해주어야 한다.

```
oc -n cicd-demo create secret docker-registry mirror-reg-pull \
    --docker-server=bastion.redhat2.cccr.local:5000 \
    --docker-username=devops \
    --docker-password=dkagh1.  \
    --docker-email='hyukjun1994@gmail.com'

oc -n dev-demo create secret docker-registry mirror-reg-pull \
    --docker-server=bastion.redhat2.cccr.local:5000 \
    --docker-username=devops \
    --docker-password=dkagh1.  \
    --docker-email='hyukjun1994@gmail.com'
	
oc -n stage-demo create secret docker-registry mirror-reg-pull \
    --docker-server=bastion.redhat2.cccr.local:5000 \
    --docker-username=devops \
    --docker-password=dkagh1.  \
    --docker-email='hyukjun1994@gmail.com'

oc -n cicd-demo create secret docker-registry quay-cicd-secret \
    --docker-server=quay.redhat2.cccr.local \
    --docker-username=admin \
    --docker-password=password  \
    --docker-email='hyukjun1994@gmail.com'

oc -n dev-demo create secret docker-registry quay-cicd-secret \
    --docker-server=quay.redhat2.cccr.local \
    --docker-username=admin \
    --docker-password=password  \
    --docker-email='hyukjun1994@gmail.com'

oc -n stage-demo create secret docker-registry quay-cicd-secret \
    --docker-server=quay.redhat2.cccr.local \
    --docker-username=admin \
    --docker-password=password  \
    --docker-email='hyukjun1994@gmail.com'

oc -n cicd-demo secret link builder mirror-reg-pull
oc -n dev-demo secret link builder mirror-reg-pull
oc -n stage-demo secret link builder mirror-reg-pull

oc -n cicd-demo secret link default --for=pull quay-cicd-secret
oc -n dev-demo secret link default --for=pull quay-cicd-secret
oc -n stage-demo secret link default --for=pull quay-cicd-secret
```

### 3. import images for ci/cd tools

> 해당 작업을 위해서는 cluster-admin 권한이 필요하다.

- 위에서 받은 skopeo 이미지도 import가 필요하다.
    - maven, podman, skopeo 도구들은 jenkins에 agent로 올려야 한다.
        - 그래야 파이프라인 실행 시, agent 'agent 이름'을 통해서 원하는 빌드 시점에 해당 agent를 label을 정해서 사용할 수 있습니다.

    ```
    oc import-image jenkins:2 --from=bastion.redhat2.cccr.local:5000/openshift4/ose-jenkins:v4.4 --confirm -n openshift
    oc import-image postgresql:9.6 --from=bastion.redhat2.cccr.local:5000/rhscl/postgresql-96-rhel7:latest --confirm -n openshift
    oc import-image eap72-openshift:1.2 --from=bastion.redhat2.cccr.local:5000/jboss-eap-7/eap72-openshift:1.2 --confirm -n openshift
    oc import-image sonarqube:latest --from=bastion.redhat2.cccr.local:5000/siamaksade/sonarqube:latest --confirm -n cicd-demo
    oc import-image gogs:0.11.34 --from=bastion.redhat2.cccr.local:5000/openshiftdemos/gogs:0.11.34 --confirm -n cicd-demo
    ```

### 4. create templates for ci/cd tools

> 해당 작업을 위해서는 cluster-admin 권한이 필요하다.

- jenkins template 파일 생성

    ```bash
    cat <<EOF > ocp-jenkins-template.json
    {
        "apiVersion": "v1",
        "kind": "Template",
        "labels": {
            "app": "jenkins-ephemeral",
            "template": "jenkins-ephemeral-template"
        },
        "message": "A Jenkins service has been created in your project.  Log into Jenkins with your OpenShift account.  The tutorial at https://github.com/openshift/origin/blob/master/examples/jenkins/README.md contains more information about using this template.",
        "metadata": {
            "annotations": {
                "description": "Jenkins service, without persistent storage.\n\nWARNING: Any data stored will be lost upon pod destruction. Only use this template for testing.",
                "iconClass": "icon-jenkins",
                "openshift.io/display-name": "Jenkins (Ephemeral)",
                "openshift.io/documentation-url": "https://docs.okd.io/latest/using_images/other_images/jenkins.html",
                "openshift.io/long-description": "This template deploys a Jenkins server capable of managing OpenShift Pipeline builds and supporting OpenShift-based oauth login.  The Jenkins configuration is stored in non-persistent storage, so this configuration should be used for experimental purposes only.",
                "openshift.io/provider-display-name": "Red Hat, Inc.",
                "openshift.io/support-url": "https://access.redhat.com",
                "tags": "instant-app,jenkins"
            },
            "name": "jenkins-ephemeral"
        },
        "objects": [
            {
                "apiVersion": "v1",
                "kind": "Route",
                "metadata": {
                    "annotations": {
                        "haproxy.router.openshift.io/timeout": "4m",
                        "template.openshift.io/expose-uri": "http://{.spec.host}{.spec.path}"
                    },
                    "name": "${JENKINS_SERVICE_NAME}"
                },
                "spec": {
                    "tls": {
                        "insecureEdgeTerminationPolicy": "Redirect",
                        "termination": "edge"
                    },
                    "to": {
                        "kind": "Service",
                        "name": "${JENKINS_SERVICE_NAME}"
                    }
                }
            },
            {
                "apiVersion": "v1",
                "kind": "DeploymentConfig",
                "metadata": {
                    "annotations": {
                        "template.alpha.openshift.io/wait-for-ready": "true"
                    },
                    "name": "${JENKINS_SERVICE_NAME}"
                },
                "spec": {
                    "replicas": 1,
                    "selector": {
                        "name": "${JENKINS_SERVICE_NAME}"
                    },
                    "strategy": {
                        "type": "Recreate"
                    },
                    "template": {
                        "metadata": {
                            "labels": {
                                "name": "${JENKINS_SERVICE_NAME}"
                            }
                        },
                        "spec": {
                            "containers": [
                                {
                                    "env": [
                                        {
                                            "name": "OPENSHIFT_ENABLE_OAUTH",
                                            "value": "${ENABLE_OAUTH}"
                                        },
                                        {
                                            "name": "OPENSHIFT_ENABLE_REDIRECT_PROMPT",
                                            "value": "true"
                                        },
                                        {
                                            "name": "DISABLE_ADMINISTRATIVE_MONITORS",
                                            "value": "${DISABLE_ADMINISTRATIVE_MONITORS}"
                                        },
                                        {
                                            "name": "KUBERNETES_MASTER",
                                            "value": "https://kubernetes.default:443"
                                        },
                                        {
                                            "name": "KUBERNETES_TRUST_CERTIFICATES",
                                            "value": "true"
                                        },
                                        {
                                            "name": "JENKINS_SERVICE_NAME",
                                            "value": "${JENKINS_SERVICE_NAME}"
                                        },
                                        {
                                            "name": "JNLP_SERVICE_NAME",
                                            "value": "${JNLP_SERVICE_NAME}"
                                        }
                                    ],
                                    "image": " ",
                                    "imagePullPolicy": "IfNotPresent",
                                    "livenessProbe": {
                                        "failureThreshold": 2,
                                        "httpGet": {
                                            "path": "/login",
                                            "port": 8080
                                        },
                                        "initialDelaySeconds": 420,
                                        "periodSeconds": 360,
                                        "timeoutSeconds": 240
                                    },
                                    "name": "jenkins",
                                    "readinessProbe": {
                                        "httpGet": {
                                            "path": "/login",
                                            "port": 8080
                                        },
                                        "initialDelaySeconds": 3,
                                        "timeoutSeconds": 240
                                    },
                                    "resources": {
                                        "limits": {
                                            "memory": "${MEMORY_LIMIT}"
                                        }
                                    },
                                    "securityContext": {
                                        "capabilities": {},
                                        "privileged": false
                                    },
                                    "terminationMessagePath": "/dev/termination-log",
                                    "volumeMounts": [
                                        {
                                            "mountPath": "/var/lib/jenkins",
                                            "name": "${JENKINS_SERVICE_NAME}-data"
                                        }
                                    ]
                                }
                            ],
                            "dnsPolicy": "ClusterFirst",
                            "restartPolicy": "Always",
                            "serviceAccountName": "${JENKINS_SERVICE_NAMEJENKINS_SERVICE_NAME}",
                            "volumes": [
                                {
                                    "emptyDir": {
                                        "medium": ""
                                    },
                                    "name": "${JENKINS_SERVICE_NAME}-data"
                                }
                            ]
                        }
                    },
                    "triggers": [
                        {
                            "imageChangeParams": {
                      23          "automatic": true,
                                "containerNames": [
                                    "jenkins"
                                ],
                                "from": {
                                    "kind": "ImageStreamTag",
                                    "name": "${JENKINS_IMAGE_STREAM_TAG}",
                                    "namespace": "${NAMESPACE}"
                                },
                                "lastTriggeredImage": ""
                            },
                            "type": "ImageChange"
                        },
                        {
                            "type": "ConfigChange"
                        }
                    ]
                }
            },
            {
                "apiVersion": "v1",
                "kind": "ServiceAccount",
                "metadata": {
                    "annotations": {
                        "serviceaccounts.openshift.io/oauth-redirectreference.jenkins": "{\"kind\":\"OAuthRedirectReference\",\"apiVersion\":\"v1\",\"reference\":{\"kind\":\"Route\",\"name\":\"${JENKINS_SERVICE_NAME}\"}}"
                    },
                    "name": "${JENKINS_SERVICE_NAME}"
                }
            },
            {
                "apiVersion": "v1",
                "groupNames": null,
                "kind": "RoleBinding",
                "metadata": {
                    "name": "${JENKINS_SERVICE_NAME}_edit"
                },
                "roleRef": {
                    "name": "edit"
                },
                "subjects": [
                    {
                        "kind": "ServiceAccount",
                        "name": "${JENKINS_SERVICE_NAME}"
                    }
                ]
            },
            {
                "apiVersion": "v1",
                "kind": "Service",
                "metadata": {
                    "name": "${JNLP_SERVICE_NAME}"
                },
                "spec": {
                    "ports": [
                        {
                            "name": "agent",
                            "nodePort": 0,
                            "port": 50000,
                            "protocol": "TCP",
                            "targetPort": 50000
                        }
                    ],
                    "selector": {
                        "name": "${JENKINS_SERVICE_NAME}"
                    },
                    "sessionAffinity": "None",
                    "type": "ClusterIP"
                }
            },
            {
                "apiVersion": "v1",
                "kind": "Service",
                "metadata": {
                    "annotations": {
                        "service.alpha.openshift.io/dependencies": "[{\"name\": \"${JNLP_SERVICE_NAME}\", \"namespace\": \"\", \"kind\": \"Service\"}]",
                        "service.openshift.io/infrastructure": "true"
                    },
                    "name": "${JENKINS_SERVICE_NAME}"
                },
                "spec": {
                    "ports": [
                        {
                            "name": "web",
                            "nodePort": 0,
                            "port": 80,
                            "protocol": "TCP",
                            "targetPort": 8080
                        }
                    ],
                    "selector": {
                        "name": "${JENKINS_SERVICE_NAME}"
                    },
                    "sessionAffinity": "None",
                    "type": "ClusterIP"
                }
            }
        ],
        "parameters": [
            {
                "description": "The name of the OpenShift Service exposed for the Jenkins container.",
                "displayName": "Jenkins Service Name",
                "name": "JENKINS_SERVICE_NAME",
                "value": "jenkins"
            },
            {
                "description": "The name of the service used for master/slave communication.",
                "displayName": "Jenkins JNLP Service Name",
                "name": "JNLP_SERVICE_NAME",
                "value": "jenkins-jnlp"
            },
            {
                "description": "Whether to enable OAuth OpenShift integration. If false, the static account 'admin' will be initialized with the password 'password'.",
                "displayName": "Enable OAuth in Jenkins",
                "name": "ENABLE_OAUTH",
                "value": "true"
            },
            {
                "description": "Maximum amount of memory the container can use.",
                "displayName": "Memory Limit",
                "name": "MEMORY_LIMIT",
                "value": "512Mi"
            },
            {
                "description": "The OpenShift Namespace where the Jenkins ImageStream resides.",
                "displayName": "Jenkins ImageStream Namespace",
                "name": "NAMESPACE",
                "value": "openshift"
            },
            {
                "description": "Whether to perform memory intensive, possibly slow, synchronization with the Jenkins Update Center on start.  If true, the Jenkins core update monitor and site warnings monitor are disabled.",
                "displayName": "Disable memory intensive administrative monitors",
                "name": "DISABLE_ADMINISTRATIVE_MONITORS",
                "value": "false"
            },
            {
                "description": "Name of the ImageStreamTag to be used for the Jenkins image.",
                "displayName": "Jenkins ImageStreamTag",
                "name": "JENKINS_IMAGE_STREAM_TAG",
                "value": "jenkins:2"
            }
        ]
    }

    EOF
    ```

    - jenkins template을 openshift 프로젝트에 등록

    ```
    oc create -f ocp-jenkins-template.json -n openshift
    ```

    - gogs template 파일 생성

    ```
    cat <<EOF > gogs-template-ephemeral.yaml
    kind: Template
    apiVersion: v1
    metadata:
      annotations:
        description: The Gogs git server (<https://gogs.io/>)
        tags: instant-app,gogs,go,golang
      name: gogs
    objects:
    - kind: ServiceAccount
      apiVersion: v1
      metadata:
        labels:
          app: ${APPLICATION_NAME}
        name: ${APPLICATION_NAME}
    - kind: Service
      apiVersion: v1
      metadata:
        annotations:
          description: Exposes the database server
        name: ${APPLICATION_NAME}-postgresql
      spec:
        ports:
        - name: postgresql
          port: 5432
          targetPort: 5432
        selector:
          name: ${APPLICATION_NAME}-postgresql
    - kind: DeploymentConfig
      apiVersion: v1
      metadata:
        annotations:
          description: Defines how to deploy the database
        name: ${APPLICATION_NAME}-postgresql
        labels:
          app: ${APPLICATION_NAME}
      spec:
        replicas: 1
        selector:
          name: ${APPLICATION_NAME}-postgresql
        strategy:
          type: Recreate
        template:
          metadata:
            labels:
              name: ${APPLICATION_NAME}-postgresql
            name: ${APPLICATION_NAME}-postgresql
          spec:
            serviceAccountName: ${APPLICATION_NAME}
            containers:
            - env:
              - name: POSTGRESQL_USER
                value: ${DATABASE_USER}
              - name: POSTGRESQL_PASSWORD
                value: ${DATABASE_PASSWORD}
              - name: POSTGRESQL_DATABASE
                value: ${DATABASE_NAME}
              - name: POSTGRESQL_MAX_CONNECTIONS
                value: ${DATABASE_MAX_CONNECTIONS}
              - name: POSTGRESQL_SHARED_BUFFERS
                value: ${DATABASE_SHARED_BUFFERS}
              - name: POSTGRESQL_ADMIN_PASSWORD
                value: ${DATABASE_ADMIN_PASSWORD}
              image: ' '
              livenessProbe:
                initialDelaySeconds: 30
                tcpSocket:
                  port: 5432
                timeoutSeconds: 1
              name: postgresql
              ports:
              - containerPort: 5432
              readinessProbe:
                exec:
                  command:
                  - /bin/sh
                  - -i
                  - -c
                  - psql -h 127.0.0.1 -U ${POSTGRESQL_USER} -q -d ${POSTGRESQL_DATABASE} -c 'SELECT 1'
                initialDelaySeconds: 5
                timeoutSeconds: 1
              resources:
                limits:
                  memory: 512Mi
              volumeMounts:
              - mountPath: /var/lib/pgsql/data
                name: gogs-postgres-data
            volumes:
            - name: gogs-postgres-data
              emptyDir: {}
        triggers:
        - imageChangeParams:
            automatic: true
            containerNames:
            - postgresql
            from:
              kind: ImageStreamTag
              name: postgresql:${DATABASE_VERSION}
              namespace: openshift
          type: ImageChange
        - type: ConfigChange
    - kind: Service
      apiVersion: v1
      metadata:
        annotations:
          description: The Gogs server's http port
          service.alpha.openshift.io/dependencies: '[{"name":"${APPLICATION_NAME}-postgresql","namespace":"","kind":"Service"}]'
        labels:
          app: ${APPLICATION_NAME}
        name: ${APPLICATION_NAME}
      spec:
        ports:
        - name: 3000-tcp
          port: 3000
          protocol: TCP
          targetPort: 3000
        - name: 10022-tcp
          port: 10022
          protocol: TCP
          targetPort: 10022
        selector:
          app: ${APPLICATION_NAME}
          deploymentconfig: ${APPLICATION_NAME}
        sessionAffinity: None
        type: ClusterIP
    - kind: Route
      apiVersion: v1
      id: ${APPLICATION_NAME}-http
      metadata:
        annotations:
          description: Route for application's http service.
        labels:
          app: ${APPLICATION_NAME}
        name: ${APPLICATION_NAME}
      spec:
        host: ${HOSTNAME}
        port:
          targetPort: 3000-tcp
        to:
          name: ${APPLICATION_NAME}
    - kind: Route
      apiVersion: v1
      id: ${APPLICATION_NAME}-ssh
      metadata:
        annotations:
          description: Route for application's ssh service.
        labels:
          app: ${APPLICATION_NAME}
        name: ${APPLICATION_NAME}-ssh
      spec:
        host: secure${HOSTNAME}
        port:
          targetPort: 10022-tcp
        to:
          name: ${APPLICATION_NAME}
    - kind: DeploymentConfig
      apiVersion: v1
      metadata:
        labels:
          app: ${APPLICATION_NAME}
        name: ${APPLICATION_NAME}
      spec:
        replicas: 1
        selector:
          app: ${APPLICATION_NAME}
          deploymentconfig: ${APPLICATION_NAME}
        strategy:
          resources: {}
          rollingParams:
            intervalSeconds: 1
            maxSurge: 25%
            maxUnavailable: 25%
            timeoutSeconds: 600
            updatePeriodSeconds: 1
          type: Rolling
        template:
          metadata:
            creationTimestamp: null
            labels:
              app: ${APPLICATION_NAME}
              deploymentconfig: ${APPLICATION_NAME}
          spec:
            serviceAccountName: ${APPLICATION_NAME}
            containers:
            - image: " "
              imagePullPolicy: Always
              name: ${APPLICATION_NAME}
              ports:
              - containerPort: 3000
                protocol: TCP
              - containerPort: 10022
                protocol: TCP
              resources: {}
              terminationMessagePath: /dev/termination-log
              volumeMounts:
              - name: gogs-data
                mountPath: /opt/gogs/data
              - name: gogs-config
                mountPath: /etc/gogs/conf
              readinessProbe:
                  httpGet:
                    path: /
                    port: 3000
                    scheme: HTTP
                  initialDelaySeconds: 3
                  timeoutSeconds: 1
                  periodSeconds: 20
                  successThreshold: 1
                  failureThreshold: 3
              livenessProbe:
                  httpGet:
                    path: /
                    port: 3000
                    scheme: HTTP
                  initialDelaySeconds: 3
                  timeoutSeconds: 1
                  periodSeconds: 10
                  successThreshold: 1
                  failureThreshold: 3
            dnsPolicy: ClusterFirst
            restartPolicy: Always
            securityContext: {}
            terminationGracePeriodSeconds: 30
            volumes:
            - name: gogs-data
              emptyDir: {}
            - name: gogs-config
              configMap:
                name: gogs-config
                items:
                  - key: app.ini
                    path: app.ini
        test: false
        triggers:
        - type: ConfigChange
        - imageChangeParams:
            automatic: true
            containerNames:
            - ${APPLICATION_NAME}
            from:
              kind: ImageStreamTag
              name: ${APPLICATION_NAME}:${GOGS_VERSION}
          type: ImageChange
    - kind: ImageStream
      apiVersion: v1
      metadata:
        labels:
          app: ${APPLICATION_NAME}
        name: ${APPLICATION_NAME}
      spec:
        tags:
        - name: "${GOGS_VERSION}"
          from:
            kind: DockerImage
            name: docker.io/openshiftdemos/gogs:${GOGS_VERSION}
          importPolicy: {}
          annotations:
            description: The Gogs git server docker image
            tags: gogs,go,golang
            version: "${GOGS_VERSION}"
    - kind: ConfigMap
      apiVersion: v1
      metadata:
        name: gogs-config
        labels:
          app: ${APPLICATION_NAME}
      data:
        app.ini: |
          RUN_MODE = prod
          RUN_USER = gogs

          [database]
          DB_TYPE  = postgres
          HOST     = ${APPLICATION_NAME}-postgresql:5432
          NAME     = ${DATABASE_NAME}
          USER     = ${DATABASE_USER}
          PASSWD   = ${DATABASE_PASSWORD}

          [repository]
          ROOT = /opt/gogs/data/repositories

          [server]
          ROOT_URL=http://${HOSTNAME}
          SSH_DOMAIN=secure${HOSTNAME}
          START_SSH_SERVER=true
          SSH_LISTEN_PORT=10022

          [security]
          INSTALL_LOCK = ${INSTALL_LOCK}

          [service]
          ENABLE_CAPTCHA = false

          [webhook]
          SKIP_TLS_VERIFY = ${SKIP_TLS_VERIFY}
    parameters:
    - description: The name for the application.
      name: APPLICATION_NAME
      required: true
      value: gogs
    - description: 'Custom hostname for http service route.  Leave blank for default hostname, e.g.: <application-name>-<project>.<default-domain-suffix>'
      name: HOSTNAME
      required: true
    - displayName: Database Username
      from: gogs
      value: gogs
      name: DATABASE_USER
    - displayName: Database Password
      from: '[a-zA-Z0-9]{8}'
      value: gogs
      name: DATABASE_PASSWORD
    - displayName: Database Name
      name: DATABASE_NAME
      value: gogs
    - displayName: Database Admin Password
      from: '[a-zA-Z0-9]{8}'
      generate: expression
      name: DATABASE_ADMIN_PASSWORD
    - displayName: Maximum Database Connections
      name: DATABASE_MAX_CONNECTIONS
      value: "100"
    - displayName: Shared Buffer Amount
      name: DATABASE_SHARED_BUFFERS
      value: 12MB
    - displayName: Database version (PostgreSQL)
      name: DATABASE_VERSION
      value: "9.5"
    - name: GOGS_VERSION
      displayName: Gogs Version
      description: 'Version of the Gogs container image to be used (check the available version <https://hub.docker.com/r/openshiftdemos/gogs/tags>)'
      value: "0.11.34"
      required: true
    - name: INSTALL_LOCK
      displayName: Installation lock
      description: 'If set to true, installation (/install) page will be disabled. Set to false if you want to run the installation wizard via web'
      value: "true"
    - name: SKIP_TLS_VERIFY
      displayName: Skip TLS verification on webhooks
      description: Skip TLS verification on webhooks. Enable with caution!

    EOF

    ```

    - gogs template image 정보 갱신

    ```
    PRV_REG=registry.demo.ocp4.com:5000    # mirror registry url
    sed -i 's/docker.io\\/openshiftdemos\\/gogs/${PRV_REG}\\/openshiftdemos\\/gogs/g' gogs-template-ephemeral.yaml

    ```

    - sonarqube-template 파일 생성

    ```
    cat <<EOF > sonarqube-template.yml 
    apiVersion: v1
    kind: Template
    metadata:
      name: "sonarqube"
    objects:

    - apiVersion: v1
      kind: ImageStream
      metadata:
        labels:
          app: sonarqube
        name: sonarqube
      spec:
        tags:
        - annotations:
          description: The SonarQube Docker image
          tags: sonarqube
          from:
            kind: DockerImage
            name: docker.io/siamaksade/sonarqube:latest
          importPolicy: {}
          name: latest
    - apiVersion: v1
      kind: Secret
      stringData:
        database-name: ${POSTGRES_DATABASE_NAME}
        database-password: ${POSTGRES_PASSWORD}
        database-user: ${POSTGRES_USERNAME}
      metadata:
        labels:
          app: sonarqube
          template: postgresql-template
        name: sonardb
      type: Opaque
    - apiVersion: v1
      stringData:
        password: ${SONAR_LDAP_BIND_PASSWORD}
        username: ${SONAR_LDAP_BIND_DN}
      kind: Secret
      metadata:
        name: sonar-ldap-bind-dn
      type: kubernetes.io/basic-auth
    - apiVersion: v1
      kind: DeploymentConfig
      metadata:
        generation: 1
        labels:
          app: sonarqube
          template: postgresql-template
        name: sonardb
      spec:
        replicas: 1
        selector:
          name: sonardb
        strategy:
          activeDeadlineSeconds: 21600
          recreateParams:
            timeoutSeconds: 600
          resources: {}
          type: Recreate
        template:
          metadata:
            labels:
              name: sonardb
          spec:
            containers:
            - env:
              - name: POSTGRESQL_USER
                valueFrom:
                  secretKeyRef:
                    key: database-user
                    name: sonardb
              - name: POSTGRESQL_PASSWORD
                valueFrom:
                  secretKeyRef:
                    key: database-password
                    name: sonardb
              - name: POSTGRESQL_DATABASE
                valueFrom:
                  secretKeyRef:
                    key: database-name
                    name: sonardb
              imagePullPolicy: IfNotPresent
              livenessProbe:
                failureThreshold: 3
                initialDelaySeconds: 30
                periodSeconds: 10
                successThreshold: 1
                tcpSocket:
                  port: 5432
                timeoutSeconds: 1
              name: postgresql
              ports:
              - containerPort: 5432
                protocol: TCP
              readinessProbe:
                exec:
                  command:
                  - /bin/sh
                  - -i
                  - -c
                  - psql -h 127.0.0.1 -U $POSTGRESQL_USER -q -d $POSTGRESQL_DATABASE -c
                    'SELECT 1'
                failureThreshold: 3
                initialDelaySeconds: 5
                periodSeconds: 10
                successThreshold: 1
                timeoutSeconds: 1
              resources:
                limits:
                  memory: ${POSTGRES_CONTAINER_MEMORY_SIZE_LIMIT}
                  cpu: ${POSTGRES_CONTAINER_CPU_LIMIT}
                requests:
                  memory: 1Gi
              securityContext:
                capabilities: {}
                privileged: false
              terminationMessagePath: /dev/termination-log
              terminationMessagePolicy: File
              volumeMounts:
              - mountPath: /var/lib/pgsql/data
                name: sonardb-data
            dnsPolicy: ClusterFirst
            restartPolicy: Always
            schedulerName: default-scheduler
            securityContext: {}
            terminationGracePeriodSeconds: 30
            volumes:
            - name: sonardb-data
              emptyDir: {}
        test: false
        triggers:
        - imageChangeParams:
          automatic: true
          containerNames:
            - postgresql
              from:
                kind: ImageStreamTag
                name: 'postgresql:9.6'
                namespace: openshift
              type: ImageChange
        - type: ConfigChange
    - apiVersion: v1
      kind: DeploymentConfig
      metadata:
        generation: 1
        labels:
          app: sonarqube
        name: sonarqube
      spec:
        replicas: 1
        selector:
          app: sonarqube
          deploymentconfig: sonarqube
        strategy:
          activeDeadlineSeconds: 21600
          recreateParams:
            timeoutSeconds: 600
          type: Recreate
        template:
          metadata:
            labels:
              app: sonarqube
              deploymentconfig: sonarqube
          spec:
            containers:
            - env:
              - name: JDBC_URL
                value: jdbc:postgresql://sonardb:5432/sonar
              - name: JDBC_USERNAME
                valueFrom:
                  secretKeyRef:
                    key: database-user
                    name: sonardb
              - name: JDBC_PASSWORD
                valueFrom:
                  secretKeyRef:
                    key: database-password
                    name: sonardb
              - name: FORCE_AUTHENTICATION
                value: ${FORCE_AUTHENTICATION}
              - name: PROXY_HOST
                value: ${PROXY_HOST}
              - name: PROXY_PORT
                value: ${PROXY_PORT}
              - name: PROXY_USER
                value: ${PROXY_USER}
              - name: PROXY_PASSWORD
                value: ${PROXY_PASSWORD}
              - name: LDAP_URL
                value: ${SONAR_LDAP_URL}
              - name: LDAP_REALM
                value: ${SONAR_AUTH_REALM}
              - name: LDAP_AUTHENTICATION
                value: ${SONAR_LDAP_BIND_METHOD}
              - name: LDAP_USER_BASEDN
                value: ${SONAR_BASE_DN}
              - name: LDAP_USER_REAL_NAME_ATTR
                value: ${SONAR_LDAP_USER_REAL_NAME_ATTR}
              - name: LDAP_USER_EMAIL_ATTR
                value: ${SONAR_LDAP_USER_EMAIL_ATTR}
              - name: LDAP_USER_REQUEST
                value: ${SONAR_LDAP_USER_REQUEST}
              - name: LDAP_GROUP_BASEDN
                value: ${SONAR_LDAP_GROUP_BASEDN}
              - name: LDAP_GROUP_REQUEST
                value: ${SONAR_LDAP_GROUP_REQUEST}
              - name: LDAP_GROUP_ID_ATTR
                value: ${SONAR_LDAP_GROUP_ID_ATTR}
              - name: LDAP_CONTEXTFACTORY
                value: ${SONAR_LDAP_CONTEXTFACTORY}
              - name: SONAR_AUTOCREATE_USERS
                value: ${SONAR_AUTOCREATE_USERS}
              - name: LDAP_BINDDN
                valueFrom:
                  secretKeyRef:
                    key: username
                    name: sonar-ldap-bind-dn
              - name: LDAP_BINDPASSWD
                valueFrom:
                  secretKeyRef:
                    key: password
                    name: sonar-ldap-bind-dn
              imagePullPolicy: Always
              livenessProbe:
                failureThreshold: 3
                httpGet:
                  path: /
                  port: 9000
                  scheme: HTTP
                initialDelaySeconds: 45
                periodSeconds: 10
                successThreshold: 1
                timeoutSeconds: 1
              name: sonarqube
              ports:
              - containerPort: 9000
                protocol: TCP
              readinessProbe:
                failureThreshold: 3
                httpGet:
                  path: /
                  port: 9000
                  scheme: HTTP
                initialDelaySeconds: 10
                periodSeconds: 10
                successThreshold: 1
                timeoutSeconds: 1
              resources:
                requests:
                  cpu: 200m
                  memory: 1Gi
                limits:
                  cpu: ${SONARQUBE_CPU_LIMIT}
                  memory: ${SONARQUBE_MEMORY_LIMIT}
              terminationMessagePath: /dev/termination-log
              terminationMessagePolicy: File
              volumeMounts:
              - mountPath: /opt/sonarqube/data
                name: sonar-data
            dnsPolicy: ClusterFirst
            restartPolicy: Always
            schedulerName: default-scheduler
            securityContext: {}
            terminationGracePeriodSeconds: 30
            volumes:
            - name: sonar-data
              emptyDir: {}
        test: false
        triggers:
        - imageChangeParams:
          automatic: true
          containerNames:
          - sonarqube
            from:
            kind: ImageStreamTag
            name: sonarqube:latest
            type: ImageChange
        - type: ConfigChange
    - apiVersion: v1
      kind: Route
      metadata:
        labels:
          app: sonarqube
        name: sonarqube
      spec:
        port:
          targetPort: 9000-tcp
        tls:
          termination: edge
        to:
          kind: Service
          name: sonarqube
          weight: 100
        wildcardPolicy: None
    - apiVersion: v1
      kind: Service
      metadata:
        annotations:
          template.openshift.io/expose-uri: postgres://{.spec.clusterIP}:{.spec.ports[?(.name=="postgresql")].port}
        labels:
          app: sonarqube
          template: postgresql-template
        name: sonardb
      spec:
        ports:
        - name: postgresql
          port: 5432
          protocol: TCP
          targetPort: 5432
            selector:
          name: sonardb
            sessionAffinity: None
            type: ClusterIP
          status:
            loadBalancer: {}
    - apiVersion: v1
      kind: Service
      metadata:
        labels:
          app: sonarqube
        name: sonarqube
      spec:
        ports:
        - name: 9000-tcp
          port: 9000
          protocol: TCP
          targetPort: 9000
            selector:
          deploymentconfig: sonarqube
            sessionAffinity: None
            type: ClusterIP
          status:
            loadBalancer: {}
          parameters:
      - description: Password for the Posgres Database to be used by Sonarqube
        displayName: Postgres password
        name: POSTGRES_PASSWORD
        generate: expression
        from: '[a-zA-Z0-9]{16}'
        required: true
      - description: Username for the Posgres Database to be used by Sonarqube
        displayName: Postgres username
        name: POSTGRES_USERNAME
        generate: expression
        from: 'user[a-z0-9]{8}'
        required: true
      - description: Database name for the Posgres Database to be used by Sonarqube
        displayName: Postgres database name
        name: POSTGRES_DATABASE_NAME
        value: sonar
        required: true
      - description: Postgres Container Memory size limit
        displayName: Postgres Container Memory size limit
        name: POSTGRES_CONTAINER_MEMORY_SIZE_LIMIT
        value: 1Gi
      - description: Postgres Container CPU limit
        displayName: Postgres Container CPU limit
        name: POSTGRES_CONTAINER_CPU_LIMIT
        value: "1"
      - name: SONARQUBE_MEMORY_LIMIT
        description: SonarQube memory
        displayName: SonarQube memory
        value: 2Gi
      - name: SONARQUBE_CPU_LIMIT
        description: SonarQube Container CPU limit
        displayName: SonarQube Container CPU limit
        value: "2"
      - name: FORCE_AUTHENTICATION
        displayName: Force authentication
        value: "false"
      - name: SONAR_AUTH_REALM
        value: ''
        description: The type of authentication that SonarQube should be using (None or LDAP) (Ref - <https://docs.sonarqube.org/display/PLUG/LDAP+Plugin>)
        displayName: SonarQube Authentication Realm
      - name: SONAR_AUTOCREATE_USERS
        value: 'false'
        description: When using an external authentication system, should SonarQube automatically create accounts for users?
        displayName: Enable auto-creation of users from external authentication systems?
        required: true
      - name: PROXY_HOST
        description: Hostname of proxy server the SonarQube application should use to access the Internet
        displayName: Proxy server hostname/IP
      - name: PROXY_PORT
        description: TCP port of proxy server the SonarQube application should use to access the Internet
        displayName: Proxy server port
      - name: PROXY_USER
        description: Username credential when the Proxy Server requires authentication
        displayName: Proxy server username
      - name: PROXY_PASSWORD
        description: Password credential when the Proxy Server requires authentication
        displayName: Proxy server password
      - name: SONAR_LDAP_BIND_DN
        description: When using LDAP authentication, this is the Distinguished Name used for binding to the LDAP server
        displayName: LDAP Bind DN
      - name: SONAR_LDAP_BIND_PASSWORD
        description: When using LDAP for authentication, this is the password with which to bind to the LDAP server
        displayName: LDAP Bind Password
      - name: SONAR_LDAP_URL
        description: When using LDAP for authentication, this is the URL of the LDAP server in the form of ldap(s)://<hostname>:<port>
        displayName: LDAP Server URL
      - name: SONAR_LDAP_REALM
        description: When using LDAP, this allows for specifying a Realm within the directory server (Usually not used)
        displayName: LDAP Realm
      - name: SONAR_LDAP_AUTHENTICATION
        description: When using LDAP, this is the bind method (simple, GSSAPI, kerberos, CRAM-MD5, DIGEST-MD5)
        displayName: LDAP Bind Mode
      - name: SONAR_LDAP_USER_BASEDN
        description: The Base DN under which SonarQube should search for user accounts in the LDAP directory
        displayName: LDAP User Base DN
      - name: SONAR_LDAP_USER_REAL_NAME_ATTR
        description: The LDAP attribute which should be referenced to get a user's full name
        displayName: LDAP Real Name Attribute
      - name: SONAR_LDAP_USER_EMAIL_ATTR
        description: The LDAP attribute which should be referenced to get a user's e-mail address
        displayName: LDAP User E-Mail Attribute
      - name: SONAR_LDAP_USER_REQUEST
        description: An LDAP filter to be used to search for user objects in the LDAP directory
        displayName: LDAP User Request Filter
      - name: SONAR_LDAP_GROUP_BASEDN
        description: The Base DN under which SonarQube should search for groups in the LDAP directory
        displayName: LDAP Group Base DN
      - name: SONAR_LDAP_GROUP_REQUEST
        description: An LDAP filter to be used to search for group objects in the LDAP directory
        displayName: LDAP Group Request Filter
      - name: SONAR_LDAP_GROUP_ID_ATTR
        description: The LDAP attribute which should be referenced to get a group's ID
        displayName: LDAP Group Name Attribute
      - name: SONAR_LDAP_CONTEXTFACTORY
        description: The ContextFactory implementation to be used when communicating with the LDAP server
        displayName: LDAP Context Factory
        value: com.sun.jndi.ldap.LdapCtxFactory

    EOF
    ```

    - gogs template image 정보 갱신

    ```
    PRV_REG=registry.demo.ocp4.com:5000    # mirror registry url
    sed -i 's/docker.io\\/siamaksade\\/sonarqube/${PRV_REG}\\/siamaksade\\/sonarqube/g' sonarqube-template.yml
    ```

### 5. install jenkins

- jenkins 설치 및 자원 설정

```
oc new-app jenkins-ephemeral -n cicd-demo
oc set resources dc/jenkins --limits=cpu=2,memory=2Gi --requests=cpu=100m,memory=512Mi
```

- 삭제해야 할 때, 해당 하는 app 관련 정보들을 삭제하기 위한 명령어

```bash
oc delete all,configmap,pvc,serviceaccount,rolebinding --selector app=jenkins-ephemeral -n cicd-demo
oc delete all,configmap,pvc,serviceaccount,rolebinding --selector app=gogs -n cicd-demo
oc delete all,configmap,pvc,serviceaccount,rolebinding --selector app=sonarqube -n cicd-demo
```

### 6. install gogs

```
HOSTNAME=$(oc get route jenkins -o template --template='{{.spec.host}}' | sed "s/jenkins-//g")
GOGS_HOSTNAME="gogs-$HOSTNAME"
oc new-app -f gogs-template-ephemeral.yaml \
      --param=GOGS_VERSION=0.11.34 \
      --param=DATABASE_VERSION=9.6 \
      --param=HOSTNAME=$GOGS_HOSTNAME \
      --param=SKIP_TLS_VERIFY=true
```

### 7. install sonarqube

```
oc new-app -f sonarqube-template.yml --param=SONARQUBE_MEMORY_LIMIT=2Gi
oc set resources dc/sonardb --limits=cpu=500m,memory=1Gi --requests=cpu=50m,memory=128Mi
oc set resources dc/sonarqube --limits=cpu=1,memory=2Gi --requests=cpu=50m,memory=128Mi
```

## Application Initial Deploy

### 1. dev application build & deploy 생성

- name을 주어 활용해야 함.

```
oc new-build --name=demo --image-stream=eap72-openshift:1.2 --binary=true -n dev-demo
oc new-app demo:latest --allow-missing-images -n dev-demo
oc set triggers dc -l app=demo --containers=demo --from-image=demo:latest --manual -n dev-demo

oc expose dc/demo --port=8080 -n dev-demo
oc expose svc/demo -n dev-demo
oc set probe -n dev-demo dc/demo --readiness -- /bin/bash -c /opt/eap/bin/readinessProbe.sh
oc set probe -n dev-demo dc/demo --liveness --initial-delay-seconds=60 -- /bin/bash -c /opt/eap/bin/livenessProbe.sh 
oc rollout cancel dc/demo -n dev-demo
```

### 2. stage application build & deploy 생성

```
oc new-app demo:stage --allow-missing-images -n stage-demo
oc set triggers dc -l app=demo --containers=demo --from-image=demo:stage --manual -n stage-demo

oc expose dc/demo --port=8080 -n stage-demo
oc expose svc/demo -n stage-demo
oc set probe dc/demo -n stage-demo --readiness -- /bin/bash -c /opt/eap/bin/readinessProbe.sh 
oc set probe dc/demo -n stage-demo --liveness --initial-delay-seconds=60 -- /bin/bash -c /opt/eap/bin/livenessProbe.sh
oc rollout cancel dc/demo -n stage-demo

```

## Prepare application

- requirement : gogs user is already created through gogs web ui

### 1. internet 접속이 가능한 환경에서 sample appllication clone

- internet 접속이 가능한 환경에서 clone한 application을 bastion 서버로 업로드

```
git clone https://github.com/OpenShiftDemos/openshift-tasks.git
tar cvf openshift-tasks.tar openshift-tasks
```

### 2. OCP의 gogs에 sample application push

> Bastion 서버에서 작업해야 함

```
GOGS_HOSTNAME=$(oc get route gogs -o template --template='{{.spec.host}}')
cd openshift-tasks
git remote set-url origin http://${GOGS_HOSTNAME}/gogs/openshift-tasks.git
git push -u origin master
```

### 3. nexus repository 관련 설정

- pom.xml

```
...
    <distributionManagement>
        <repository>
            <id>nexus</id>
            <!-- change releases repository url -->
            <url>http://<***nexus ip***>/repository/maven-releases/</url>
        </repository>
        <snapshotRepository>
            <id>nexus</id>
            <!-- change snapshot repository url -->
            <url>http://<***nexus ip***>/repository/maven-snapshots/</url>
        </snapshotRepository>
    </distributionManagement>
...
```

- configuration/cicd-settings-nexus3.xml
    - maven 버전에 따라서 repository 이름이 달라질 수 있다는 것에 주의

```
<settings>
    <servers>
        <server>
            <id>nexus</id>
            <!-- change nexus id/pw -->
            <username>admin</username>
            <password>admin123</password>
        </server>
    </servers>
    <mirrors>
        <mirror>
            <id>nexus</id>
            <mirrorOf>*</mirrorOf>
            <!-- change nexus url -->
            <url>http://<***nexus ip***>:8081/repository/maven-public/</url>
        </mirror>
    </mirrors>
...
```

## Nexus Repository 구성

> nexus의 경우 container 방식으로 OCP 노드들이 접근 가능한 서버에 internet 접속이 가능하게 구성하여 진행한다.

- pull nexus image

```
podman pull docker.io/sonatype/nexus3:latest

```

- run nexus image

> selinux 확인 필요(disable or set context)

```
mkdir -p /opt/sonartype/nexus-data && chown -R 200 /opt/sonartype/nexus-data
podman run -d -p 8081:8081 --name nexus -v /opt/sonartype/nexus-data:/nexus-data sonatype/nexus3
```

- add redhat jboss repository to nexus
    - Nexus 내부에서 UI를 통해 repository를 만들고 public에 등록해주면 됨
    - 

> sample application에서 jboss maven repository를 사용하기 때문에 추가해야 함

> 다른 application으로 진행할 경우 이번 절차는 필요 없음

```
General availability repository: <https://maven.repository.redhat.com/ga/>
Early-access repository: <https://maven.repository.redhat.com/earlyaccess/all/>
```

[6.3. Configure Maven to Use the Online Repositories Red Hat JBoss Fuse 6.2.1 | Red Hat Customer Portal](https://access.redhat.com/documentation/en-us/red_hat_jboss_fuse/6.2.1/html/installation_on_jboss_eap/configure_the_jboss_eap_integration_maven_repository_using_the_maven_settings)

[Using Nexus 3 as Your Repository - Part 1: Maven Artifacts](https://blog.sonatype.com/using-nexus-3-as-your-repository-part-1-maven-artifacts)

## Create pipeline build

- jenkins pipeline build template 작성

```
piVersion: v1
kind: Template
labels:
  template: cicd
  group: cicd
metadata:
  annotations:
    iconClass: icon-jenkins
    tags: instant-app,jenkins,gogs,nexus,cicd
  name: cicd
message: "Use the following credentials for login:\nJenkins: use your OpenShift credentials\nNexus: admin/admin123\nSonarQube: admin/admin\nGogs Git Server: gogs/gogs"
parameters:
- displayName: DEV project name
  value: dev
  name: DEV_PROJECT
  required: true
- displayName: STAGE project name
  value: stage
  name: STAGE_PROJECT
  required: true
- displayName: Ephemeral
  description: Use no persistent storage for Gogs and Nexus
  value: "true"
  name: EPHEMERAL
  required: true
- description: Webhook secret
  from: '[a-zA-Z0-9]{8}'
  generate: expression
  name: WEBHOOK_SECRET
  required: true
- displayName: Integrate Quay.io
  description: Integrate image build and deployment with Quay.io
  value: "true"
  name: ENABLE_QUAY
  required: true
- displayName: Quay.io Username
  description: Quay.io username to push the images to tasks-sample-app repository on your Quay.io account
  name: QUAY_USERNAME
  value: admin
- displayName: Quay.io Password
  description: Quay.io password to push the images to tasks-sample-app repository on your Quay.io account
  name: QUAY_PASSWORD
  value: password
- displayName: Quay.io Image Repository
  description: Quay.io repository for pushing Tasks container images
  name: QUAY_REPOSITORY
  required: true
  value: ubi7
objects:
- apiVersion: v1
  kind: BuildConfig
  metadata:
    annotations:
      pipeline.alpha.openshift.io/uses: '[{"name": "jenkins", "namespace": "", "kind": "DeploymentConfig"}]'
    labels:
      app: cicd-pipeline
      name: cicd-pipeline
    name: tasks-pipeline
  spec:
    triggers:
      - type: GitHub
        github:
          secret: ${WEBHOOK_SECRET}
      - type: Generic
        generic:
          secret: ${WEBHOOK_SECRET}
    runPolicy: Serial
    source:
      type: None
    strategy:
      jenkinsPipelineStrategy:
        env:
        - name: DEV_PROJECT
          value: ${DEV_PROJECT}
        - name: STAGE_PROJECT
          value: ${STAGE_PROJECT}
        - name: ENABLE_QUAY
          value: ${ENABLE_QUAY}
        jenkinsfile: |-
          def mvnCmd = "mvn -s configuration/cicd-settings-nexus3.xml"
          pipeline {
            agent {
              label 'maven'
            }
            stages {
              stage('Build App') {
                steps {
                  git branch: 'master',url: 'http://root:dkagh1..@10.10.10.21:18080/root/openshift-tasks.git'
                  sh "${mvnCmd} install -DskipTests=true"
                }
              }
              stage('Test') {
                steps {
                  sh "${mvnCmd} test"
                  step([$class: 'JUnitResultArchiver', testResults: '**/target/surefire-reports/TEST-*.xml'])
                }
              }
              stage('Code Analysis') {
                steps {
                  script {
                    sh "${mvnCmd} sonar:sonar -Dsonar.host.url=http://sonarqube:9000 -DskipTests=true"
                  }
                }
              }
              stage('Archive App') {
                steps {
                  sh "${mvnCmd} deploy -DskipTests=true -P nexus"
                }
              stage('Build Image') {
                steps {
                  sh "cp target/openshift-tasks.war target/ROOT.war"
                  script {
                    openshift.withCluster() {
                      openshift.withProject(env.DEV_PROJECT) {
                        openshift.selector("bc", "demo").startBuild("--from-file=target/ROOT.war", "--wait=true")
                      }
                    }
                  }
                }
              }
              stage('Send to QUAY') {
                agent {
                  label 'skopeo'
                }
                steps {
                  script {
                    sh '''
                  oc login https://api.redhat2.cccr.local:6443 -u kubeadmin -p qMZXS-eoF9S-W46LX-USXoj --insecure-skip-tls-verify=true
                  oc project dev-demo
                  skopeo copy --src-tls-verify=false --dest-tls-verify=false --src-creds kubeadmin:`oc whoami -t` --dest-creds 'admin:password' docker://image-registry.openshift-image-registry.svc:5000/dev-demo/demo:latest docker://quay.redhat2.cccr.local/admin/demo:stage
                  '''
                  }
                }
              }
              stage('Deploy DEV') {
                steps {
                  script {
                    openshift.withCluster() {
                      openshift.withProject(env.DEV_PROJECT) {
                        openshift.selector("dc", "demo").rollout().latest();
                      }
                    }
                  }
                }
              }
              stage('Deploy STAGE? Promote or Abort') {
                steps {
                  timeout(time:15, unit:'MINUTES') {
                      input message: "Promote to STAGE?", ok: "Promote"
                  }
                  script {
                    openshift.withCluster() {
                      openshift.tag("${env.DEV_PROJECT}/demo:latest", "${env.STAGE_PROJECT}/demo:stage")
                      openshift.withProject(env.STAGE_PROJECT) {
                        openshift.selector("dc", "demo").rollout().latest();
                      }
                    }
                  }
                }
              }
            }
          }
      type: JenkinsPipeline

```

- 생성된 template으로 jenkins pipeline build를 cicd project에 생성

```
oc new-app -f cicd-template.yaml -p DEV_PROJECT=dev-demo -p STAGE_PROJECT=stage-demo -p ENABLE_QUAY=false -n cicd-demo
```

- docker대신, podman + skopeo(image copy etc)를 요즘에는 더 많이 사용함
    - podman으로는 부족한 부분이 존재
    - skopeo : 이미지 보안을 위해 digest 값을 유지한 채로 복사, mirror 가능 ⇒ 설치 메뉴얼에 명시된 digest 값을 유지해야 할 때 주로 사용

- GitLab install in Jenkins

[gitlab-plugin](http://updates.jenkins-ci.org/download/plugins/gitlab-plugin/)

## Jenkinsfile 추가 설정

- podman을 이용한 QUAY에 업로드

```bash
stages {
            stage('Push image to QUAY') {
              steps {
                  sh "oc login https://api.redhat2.cccr.local:6443 -u kubeadmin -p qMZXS-eoF9S-W46LX-USXoj --insecure-skip-tls-verify=true"
                  sh "podman pull --creds kubeadmin:`oc whoami -t` image-registry.openshift-image-registry.svc:5000/dev-demo/demo:latest"
                  sh "podman tag image-registry.openshift-image-registry.svc:5000/dev-demo/demo:latest quay.redhat2.cccr.local/admin/demo:stage"
                  sh "podman push --creds admin:password quay.redhat2.cccr.local/admin/demo:stage"
              }
            }
          }
```

- skopeo를 이용한 QUAY에 이미지 복사
    - maven 대신 skopeo를 이용해서 이미지를 복사해서 quay에 대입

```bash
def mvnCmd = "mvn -s configuration/cicd-settings-nexus3.xml"
        pipeline {
          agent {
            label 'maven'
          }
          stages {
            stage('Promote to STAGE?') {
              agent {
                label 'skopeo'
              }
              steps {
                sh '''
                  oc login https://api.redhat2.cccr.local:6443 -u kubeadmin -p qMZXS-eoF9S-W46LX-USXoj --insecure-skip-tls-verify=true
                  oc project dev-demo
                  skopeo copy --src-tls-verify=false --dest-tls-verify=false --src-creds kubeadmin:`oc whoami -t` --dest-creds 'admin:password' docker://image-registry.openshift-image-registry.svc:5000/dev-demo/demo:latest docker://quay.redhat2.cccr.local/admin/demo:stage
                  '''
              }
            }
          }
        }
```

- 생성된 template으로 jenkins pipeline build를 cicd project에 생성 ⇒ Quay 사용하는 경우

```
oc new-app -f cicd-template.yaml -p DEV_PROJECT=dev-demo -p STAGE_PROJECT=stage-demo -n cicd-demo
```

## Coding Error

- gitLab에서 먼저 받을 때, gitlab repo에 코드를 올려야 한다.
    - gitlab에서 repo를 하나 만들어주고, git remote set-url origin을 [quay.redhat2.cccr.local](http://quay.redhat2.cccr.local) 주소로 설정 후, git push -u origin master로 넣어주어야 한다.

- openshift-task의 코드의 패키지 버전들이 최신 버전이 아니라 코드 실행 시, 오류가 발생할 수 있음
    - 패키지 버전은 maven repository 공식 홈페이지를 참고해서 의존성을 작성해준다.
    - pom.xml

    ```bash
    <?xml version="1.0" encoding="UTF-8"?>
    <!--
        JBoss, Home of Professional Open Source
        Copyright 2014, Red Hat, Inc. and/or its affiliates, and individual
        contributors by the @authors tag. See the copyright.txt in the
        distribution for a full listing of individual contributors.

        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License.
        You may obtain a copy of the License at
        http://www.apache.org/licenses/LICENSE-2.0
        Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.
    -->
    <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
        <modelVersion>4.0.0</modelVersion>

        <groupId>org.jboss.quickstarts.eap</groupId>
        <artifactId>jboss-tasks-rs</artifactId>
        <version>6.4.0-SNAPSHOT</version>
        <packaging>war</packaging>
        <name>JBoss EAP - Tasks JAX-RS App</name>
        <licenses>
            <license>
                <name>Apache License, Version 2.0</name>
                <distribution>repo</distribution>
                <url>http://www.apache.org/licenses/LICENSE-2.0.html</url>
            </license>
        </licenses>

        <properties>
            <!-- Explicitly declaring the source encoding eliminates the following message: -->
            <!-- [WARNING] Using platform encoding (UTF-8 actually) to copy filtered
                resources, i.e. build is platform dependent! -->
            <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>

            <!-- JBoss dependency versions -->
            <version.jboss.maven.plugin>7.4.Final</version.jboss.maven.plugin>

            <!-- Define the version of the JBoss BOMs we want to import to specify tested stacks. -->
            <version.jboss.bom.eap>6.4.0.GA</version.jboss.bom.eap>

            <!-- other plugin versions -->
            <version.surefire.plugin>2.19.1</version.surefire.plugin>
            <version.war.plugin>2.1.1</version.war.plugin>

            <!-- maven-compiler-plugin -->
            <maven.compiler.target>1.8</maven.compiler.target>
            <maven.compiler.source>1.8</maven.compiler.source>
        </properties>

        <repositories>
            <repository>
                <id>openshift-repository</id>
                <url>https://mirror.openshift.com/nexus/content/groups/public</url>
            </repository>
        </repositories>

        <distributionManagement>
            <repository>
                <id>nexus</id>
                <url>http://10.10.10.17:8081/repository/maven-releases</url>
            </repository>
            <snapshotRepository>
                <id>nexus</id>
                <url>http://10.10.10.17:8081/repository/maven-snapshots</url>
            </snapshotRepository>
        </distributionManagement>

        <dependencyManagement>
            <dependencies>
                <dependency>
                    <groupId>org.jboss.bom.eap</groupId>
                    <artifactId>jboss-javaee-6.0-with-tools</artifactId>
                    <version>${version.jboss.bom.eap}</version>
                    <type>pom</type>
                    <scope>import</scope>
                </dependency>
            </dependencies>
        </dependencyManagement>

        <dependencies>
            <dependency>
                <groupId>javax.xml.bind</groupId>
                <artifactId>jaxb-api</artifactId>
                <version>2.3.0</version>
            </dependency>

            <!-- Import the CDI API, we use provided scope as the API is included in JBoss EAP 6 -->
            <dependency>
                <groupId>javax.enterprise</groupId>
                <artifactId>cdi-api</artifactId>
                <scope>provided</scope>
            </dependency>

            <!-- Import the JPA API, we use provided scope as the API is included in JBoss EAP 6 -->
            <dependency>
                <groupId>org.hibernate.javax.persistence</groupId>
                <artifactId>hibernate-jpa-2.0-api</artifactId>
                <scope>provided</scope>
            </dependency>

            <!-- Import the JAX-RS API, we use provided scope as the API is included in JBoss EAP 6 -->
            <dependency>
                <groupId>org.jboss.spec.javax.ws.rs</groupId>
                <artifactId>jboss-jaxrs-api_1.1_spec</artifactId>
                <scope>provided</scope>
            </dependency>
            <dependency>
                <groupId>org.jboss.resteasy</groupId>
                <artifactId>resteasy-jackson-provider</artifactId>
                <version>2.3.1.GA</version>
                <scope>provided</scope>
            </dependency>

            <!-- Import the EJB API, we use provided scope as the API is included in JBoss EAP 6 -->
            <dependency>
                <groupId>org.jboss.spec.javax.ejb</groupId>
                <artifactId>jboss-ejb-api_3.1_spec</artifactId>
                <scope>provided</scope>
            </dependency>

            <!-- Test dependencies -->
            <dependency>
                <groupId>junit</groupId>
                <artifactId>junit</artifactId>
                <version>4.13.1</version>
                <scope>test</scope>
            </dependency>

            <dependency>
                <groupId>org.jboss.arquillian.junit</groupId>
                <artifactId>arquillian-junit-container</artifactId>
                <scope>test</scope>
            </dependency>

            <dependency>
                <groupId>org.jboss.arquillian.protocol</groupId>
                <artifactId>arquillian-protocol-servlet</artifactId>
                <scope>test</scope>
            </dependency>

            <dependency>
                <groupId>org.mockito</groupId>
                <artifactId>mockito-core</artifactId>
                <version>3.5.15</version>
                <scope>test</scope>
            </dependency>

            <dependency>
                <groupId>com.sun.jersey</groupId>
                <artifactId>jersey-client</artifactId>
                <version>1.12</version>
                <scope>test</scope>
            </dependency>
        </dependencies>

        <build>
            <!-- Maven will append the version to the finalName (which is the name
                given to the generated war, and hence the context root) -->
            <finalName>openshift-tasks</finalName>
            <plugins>
                <plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-compiler-plugin</artifactId>
                    <version>3.8.0</version>
                    <configuration>
                        <source>${maven.compiler.source}</source>
                        <target>${maven.compiler.target}</target>
                        <encoding>UTF-8</encoding>
                    </configuration>
                </plugin>
                <plugin>
                    <artifactId>maven-war-plugin</artifactId>
                    <version>${version.war.plugin}</version>
                    <configuration>
                        <!-- Java EE 6 doesn't require web.xml, Maven needs to catch up! -->
                        <failOnMissingWebXml>false</failOnMissingWebXml>
                    </configuration>
                </plugin>
                <!-- Surefire plugin is responsible for running tests
                    as part of project build -->
                <plugin>
                    <artifactId>maven-surefire-plugin</artifactId>
                    <version>${version.surefire.plugin}</version>
                </plugin>
                <!-- The JBoss AS plugin deploys your war to a local JBoss EAP container -->
                <!-- To use, run: mvn package jboss-as:deploy -->
                <plugin>
                    <groupId>org.jboss.as.plugins</groupId>
                    <artifactId>jboss-as-maven-plugin</artifactId>
                    <version>${version.jboss.maven.plugin}</version>
                </plugin>
                <plugin>
                    <groupId>org.sonarsource.scanner.maven</groupId>
                    <artifactId>sonar-maven-plugin</artifactId>
                    <version>3.5.0.1254</version>
                </plugin>
                <plugin>
                    <groupId>org.jacoco</groupId>
                    <artifactId>jacoco-maven-plugin</artifactId>
                    <version>0.8.6</version>
                    <executions>
                        <execution>
                            <id>default-prepare-agent</id>
                            <goals>
                                <goal>prepare-agent</goal>
                            </goals>
                        </execution>
                        <execution>
                            <id>default-report</id>
                            <phase>prepare-package</phase>
                            <goals>
                                <goal>report</goal>
                            </goals>
                        </execution>
                    </executions>
                </plugin>
                <plugin>
                    <groupId>org.ec4j.maven</groupId>
                    <artifactId>editorconfig-maven-plugin</artifactId>
                    <version>0.0.5</version>
                    <executions>
                        <execution>
                            <id>check</id>
                            <phase>verify</phase>
                            <goals>
                                <goal>check</goal>
                            </goals>
                        </execution>
                    </executions>
                    <configuration>
                        <excludes>
                            <exclude>deployments/**</exclude>
                            <exclude>src/main/webapp/css/*</exclude>
                            <exclude>src/main/webapp/fonts/*</exclude>
                            <exclude>src/main/webapp/img/*</exclude>
                            <exclude>src/main/webapp/js/*</exclude>
                        </excludes>
                    </configuration>
                </plugin>
            </plugins>
        </build>

        <reporting>
            <plugins>
                <plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-javadoc-plugin</artifactId>
                    <version>2.9</version>
                    <reportSets>
                        <reportSet>
                            <reports>
                                <report>javadoc</report>
                            </reports>
                        </reportSet>
                    </reportSets>
                </plugin>
                <plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-pmd-plugin</artifactId>
                    <version>3.8</version>
                </plugin>
                <plugin>
                    <groupId>org.owasp</groupId>
                    <artifactId>dependency-check-maven</artifactId>
                    <version>2.1.1</version>
                    <configuration>
                        <skipProvidedScope>true</skipProvidedScope>
                        <skipRuntimeScope>true</skipRuntimeScope>
                    </configuration>
                    <reportSets>
                        <reportSet>
                            <reports>
                                <report>aggregate</report>
                            </reports>
                        </reportSet>
                    </reportSets>
                </plugin>
                <plugin>
                    <groupId>org.jacoco</groupId>
                    <artifactId>jacoco-maven-plugin</artifactId>
                    <version>0.7.9</version>
                    <reportSets>
                        <reportSet>
                            <reports>
                                <report>report</report>
                            </reports>
                        </reportSet>
                    </reportSets>
                </plugin>
                <plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-checkstyle-plugin</artifactId>
                    <version>2.17</version>
                    <reportSets>
                        <reportSet>
                            <reports>
                                <report>checkstyle</report>
                            </reports>
                        </reportSet>
                    </reportSets>
                </plugin>
                <plugin>
                    <groupId>org.codehaus.mojo</groupId>
                    <artifactId>findbugs-maven-plugin</artifactId>
                    <version>3.0.5</version>
                </plugin>
                <plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-surefire-report-plugin</artifactId>
                    <version>2.20.1</version>
                </plugin>
                <plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-project-info-reports-plugin</artifactId>
                    <version>2.6</version>
                    <reportSets>
                        <reportSet>
                            <reports>
                                <report>summary</report>
                                <report>dependency-management</report>
                            </reports>
                        </reportSet>
                    </reportSets>
                </plugin>
            </plugins>
        </reporting>

        <profiles>
            <profile>
                <!-- The default profile skips all tests, though you can tune it to run
                    just unit tests based on a custom pattern -->
                <!-- Separate profiles are provided for running all tests, including Arquillian
                    tests that execute in the specified container -->
                <id>default</id>
                <activation>
                    <activeByDefault>true</activeByDefault>
                </activation>
                <build>
                    <plugins>
                        <plugin>
                            <artifactId>maven-surefire-plugin</artifactId>
                            <configuration>
                                <groups>org.jboss.as.quickstarts.tasksrs.category.UnitTest</groups>
                            </configuration>
                        </plugin>
                    </plugins>
                </build>
            </profile>

            <profile>
                <id>int-tests</id>
                <build>
                    <plugins>
                        <plugin>
                            <artifactId>maven-surefire-plugin</artifactId>
                            <configuration>
                                <groups>org.jboss.as.quickstarts.tasksrs.category.IntegrationTest</groups>
                            </configuration>
                        </plugin>
                    </plugins>
                </build>
            </profile>
            <profile>
                <!-- An optional Arquillian testing profile that executes tests
                    in your JBoss EAP instance -->
                <!-- This profile will start a new JBoss EAP instance, and execute
                    the test, shutting it down when done -->
                <!-- Run with: mvn clean test -Parq-jbossas-managed -->
                <id>arq-jbossas-managed</id>
                <dependencies>
                    <dependency>
                        <groupId>org.jboss.as</groupId>
                        <artifactId>jboss-as-arquillian-container-managed</artifactId>
                        <scope>test</scope>
                    </dependency>
                </dependencies>
            </profile>

            <profile>
                <!-- An optional Arquillian testing profile that executes tests
                    in a remote JBoss EAP instance -->
                <!-- Run with: mvn clean test -Parq-jbossas-remote -->
                <id>arq-jbossas-remote</id>
                <dependencies>
                    <dependency>
                        <groupId>org.jboss.as</groupId>
                        <artifactId>jboss-as-arquillian-container-remote</artifactId>
                        <scope>test</scope>
                    </dependency>
                </dependencies>
            </profile>
            <profile>
                <!-- When built in OpenShift the 'openshift' profile will be used when
                    invoking mvn. -->
                <!-- Use this profile for any OpenShift specific customization your app
                    will need. -->
                <!-- By default that is to put the resulting archive into the 'deployments'
                    folder. -->
                <!-- http://maven.apache.org/guides/mini/guide-building-for-different-environments.html -->
                <id>openshift</id>
                <build>
                    <plugins>
                        <plugin>
                            <artifactId>maven-surefire-plugin</artifactId>
                            <configuration>
                                <skip>true</skip>
                            </configuration>
                        </plugin>
                        <plugin>
                            <artifactId>maven-war-plugin</artifactId>
                            <version>2.4</version>
                            <configuration>
                                <failOnMissingWebXml>false</failOnMissingWebXml>
                                <outputDirectory>deployments</outputDirectory>
                                <warName>ROOT</warName>
                            </configuration>
                        </plugin>
                    </plugins>
                </build>
            </profile>
        </profiles>
    </project>
    ```

    - configuration 폴더 내의 nexus 설정 파일(.xml 확장자)

    ```bash
    <settings>
        <servers>
            <server>
                <id>nexus</id>
                <username>admin</username>
                <password>dkagh1.</password>
            </server>
        </servers>
        <mirrors>
            <mirror>
          <!--This sends everything else to /public -->
                <id>nexus</id>
                <mirrorOf>*</mirrorOf>
                <url>http://10.10.10.17:8081/repository/maven-public/</url>
            </mirror>
        </mirrors>
        <profiles>
            <profile>
                <id>nexus</id>
          <!--Enable snapshots for the built in central repo to direct -->
          <!--all requests to nexus via the mirror -->
                <repositories>
                    <repository>
                        <id>central</id>
                        <url>http://central</url>
                        <releases><enabled>true</enabled></releases>
                        <snapshots><enabled>true</enabled></snapshots>
                    </repository>
                </repositories>
                <pluginRepositories>
                    <pluginRepository>
                        <id>central</id>
                        <url>http://central</url>
                        <releases><enabled>true</enabled></releases>
                        <snapshots><enabled>true</enabled></snapshots>
                    </pluginRepository>
                </pluginRepositories>
            </profile>
        </profiles>
        <activeProfiles>
        <!--make the profile active all the time -->
            <activeProfile>nexus</activeProfile>
        </activeProfiles>
    </settings>
    ```

- 새로운 코드를 작성 시, gitlab에 올려서 코드가 제대로 받아오는 지, 접근이 가능한지에 대한 인증이 필수

<br></br>

---
### 참고문헌
  - https://www.redhat.com/ko/topics/devops/what-is-ci-cd
  - https://www.solutionsiq.com/agile-glossary/integration-hell/
  - https://wiki.c2.com/?IntegrationHell
  - https://www.joinc.co.kr/w/man/12/ci
  - https://idevops.online/2019/02/15/devops-ci-cd-tools/
