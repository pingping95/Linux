# Nginx Architecture

# 목표

- Front End 단에서 Apache와 비슷한 점유율을 가져가고 있는 Nginx에 대해서 알아보고자 합니다.
- Apache와 Nginx 각 특성에 대해 이해하고 차이점에 대해 알아보겠습니다.
- 추후 Nginx에 대한 이해도가 생기고 나면 Nginx - Tomcat - Oracle Databse와의 연동 또한 진행해보고자 합니다.

# 개요

## Nginx란?

- Traffic이 많은 웹 사이트의 확장성을 위해 설계한 비동기 (Asynchronous) Event-driven 구조의 웹서버 소프트웨어
- '더 적은 자원으로 더 빠르게 서비스'
- Nginx는 동시성, 대기 시간 처리, SSL (Secure Socket Layer), Static 컨텐츠, 압축 및 캐싱, 연결 및 요청 제한, 애플리케이션의 HTTP 미디어 스트리밍까지 편리하게 Offload에 필요한 주요 기능 제공

## Nginx vs Apache

- Apache
    - 쓰레드/ 프로세스 기반 구조로 요청 하나당 쓰레드 하나가 처리하는 구조
    - 사용자가 많으면 많은 쓰레드를 생성하고 메모리 및 CPU 낭비가 심해짐
    - 1 Thread per 1 Client
- Nginx
    - 비동기 Event-Driven 기반 구조
    - 다수의 연결을 효과적으로 처리 가능
    - 대부분의 코어 모듈이 Apache보다 적은 Resource로 더 빠르게 동작 가능
    - 더 적은 쓰레드로 클라이언트의 요청들을 처리 가능

## Thread와 Event-Driven

![Untitled](https://user-images.githubusercontent.com/67780144/95018026-cdf2c580-0697-11eb-88da-03a98ddc0000.png)

![Untitled 4](https://user-images.githubusercontent.com/67780144/95018032-d0edb600-0697-11eb-96de-069b5112ed78.png)

- Event-Driven 방식은 여러개의 Connection을 몽땅 다 Event Handler를 통해 비동기 방식으로 처리해 먼저 처리되는 것부터 Logic이 진행되게끔 한다.
- 새로운 요청이 들어오더라도 새로운 프로세스나 쓰레드를 생성하지 않기 때문에 생성 비용이 존재하지 않고 적은 자원으로도 효율적인 운용이 가능하다.
- 단일 서버에서도 동시에 많은 연결을 처리할 수 있다는 장점이 있다.

👉 Memcached, Redis (Remote Dictionary Storage) : In-Memory 데이터 저장소

## Nginx Architecture

- Nginx는 1개의 Master Process와 n개의 Worker Process로 구성되어 있다.
    - Master Process : 설정 파일을 읽고, 유효성을 검사, Worker 관리
    - Worker Process : 모든 요청을 관리, Worker Process의 개수를 Config 파일에서 정의되며, 정의된 Process 개수와 사용 가능한 CPU 코어 숫자에 맞게 자동으로 조정된다.

![Untitled 1](https://user-images.githubusercontent.com/67780144/95018028-cf23f280-0697-11eb-81b2-7893a9dd1fc6.png)

![Untitled 2](https://user-images.githubusercontent.com/67780144/95018029-cfbc8900-0697-11eb-968b-b502b9a2bb40.png)

## Nginx 로드밸런싱

- HTTP, TCP, UDP 모두 가능하다.

![Untitled 3](https://user-images.githubusercontent.com/67780144/95018031-d0551f80-0697-11eb-84e3-046c80546cfd.png)

### Load Balancing 설정 순서

- http Context에 있는 upstream 지시자에 서버군 그룹 이름 설정 후, 서버들의 주소를 각각 등록해준다.

1. http 컨텍스트 내의 upstream 모듈에 웹 서버 그룹의 이름 지정 후 각 서버의 주소, 속성 설정

```bash
http {
			upstream backend {
					server test1.com;
					server test2.com;
					server 192.0.0.1;
			}
}
```

- http : HTTP 로드 밸런싱임
- upstream : Nginx 백엔드 단으로 트래픽을 분산할 서버 그룹을 의미
- backend : group의 이름을 backend로 지정해주었음.
- server : 각각의 서버를 등록할 때 맨 앞에 사용하는 연산자

```bash
## 변형

http {
			upstream backend {
					server test1.com weight=5;
					server test2.com;
					server 192.0.0.1 backup;
			}
}
```

- weight : 가중치 5, 다른 서버보다 5배의 Traffic을 받으며 기본값은 1이다.
- backup : 백업 서버 (위의 두 서버가 다운되지 않는 한 트래픽 받지 않음)

2. http 컨텍스트 내의 server 모듈에 proxy_pass 설정

- 모든 웹 트래픽은 backend로 명명된 웹 서버 그룹으로 흘러가야 하며 nginx는 로드 밸런싱을 위한 proxy 서버 역할을 하기 때문에 server 모듈에 다음과 같은 설정을 한다.
- 경우에 따라 proxy_pass가 아닌 fastcgi_pass, memcached_pass, uwsgi_pass 등도 가능

```bash
server {
		location / {
				proxy_pass http://backend;
		}
}
```

- Load Balancing Algorithm 종류 (자세한 설명은 생략)
    - Round Robin
    - Least Connection
    - Generic Hash
    - IP Hash

## 미흡한 용어, 개념 학습

- Upstream Server : Upstream 서버는 다른 말로 Origin 서버라고도 부른다. 여러대의 컴퓨터가 순차적으로 어떤 일을 처리할 때 어떤 서비스를 받는 서버를 의미한다.
- Outbound 필터링
- Event-driven
- Non-Blocking

- Reference

[http://www.aosabook.org/en/nginx.html](http://www.aosabook.org/en/nginx.html)

[https://m.blog.naver.com/jhc9639/220967352282](https://m.blog.naver.com/jhc9639/220967352282)

[https://blog.naver.com/PostView.nhn?blogId=sehyunfa&logNo=221692884510&from=search&redirect=Log&widgetTypeCall=true&directAccess=false](https://blog.naver.com/PostView.nhn?blogId=sehyunfa&logNo=221692884510&from=search&redirect=Log&widgetTypeCall=true&directAccess=false)
