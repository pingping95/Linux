#!/bin/bash

## Variable
# mysql_id='root'
# mysql_dictionary='/etc/mysql'

# echo $mysql_id
# echo $mysql_dictionary

## List Variable
# 선언 >> 변수명(데이터1 데이터2 데이터3)
# 사용 >> ${변수명[인덱스 번호]}
daemons=("httpd" "mysqld" "vsftpd")
echo ${daemons[1]}      # $daemons 배열의 두 번째 인덱스에 해당하는 mysqld 출력
echo ${daemons[@]}      # $daemons 배열의 모든 데이터 출력
echo ${#daemons[@]}     # $daemons 배열 크기 출력

filelist=( $(ls) )
echo ${filelist[*]}

## 사전에 정의된 지역 변수
# $$ : 쉘의 프로세스 번호
# $0 : 쉘 스크립트 이름
# $1 ~ $9 : 명령줄 인수
# $* : 모든 명령줄 인수 리스트
# $# : 인수의 개수

## 연산자
# expr : 숫자 계산
# expr를 사용하는 경우 역 작은 따옴표 (`)를 사용해야 함
# 연산자 *와 괄호() 사이에는 역슬래시 (\) 같이 사용
# 연산자와 숫자, 변수, 기호 사이에는 space를 넣어야 함
num=`expr \( 3 \* 5 \) / 4 + 7`
echo $num

## 조건
# 조건 작성이 다른 프로그래밍 언어와 달리 가독성이 현저히 떨어짐, 필요할 때마다 참조!

## 문자 비교
# 문자1 == 문자2        # 문자 1과 문자 2가 일치
# 문자1 != 문자2        # 문자 1과 문자 2가 불일치
# -z 문자              # 문자가 null 이면 참
# -n 문자              # 문자가 null 이 아니면 참
# 문자 == 패턴
# 문자 != 패턴

## 수치 비교 : <, >는 if 조건 시 [[ ]]를 넣는 경우 정상 동작하기도 하지만, 기본적으로
## 다음 문법을 사용하는 것을 권장
# -eq       # equal
# -ne       # not equal
# -lt       # less than
# -le       # less or equal
# -gt       # greater than
# -ge       # greater or equal

## 파일 검사
# -e 파일명               # 파일이 존재하면 참
# -d 파일명               # 파일이 디렉토리면 참
# -h 파일명               # 심볼릭 링크파일
# -f 파일명               # 파일이 일반파일이면 참
# -r 파일명               # 파일이 읽기 가능이면 참
# -s 파일명               # 파일 크기가 0이 아니면 참
# -u 파일명               # 파일이 set-user-id가 설정되면 참
# -w 파일명               # 파일이 쓰기 가능 상태이면 참
# -x 파일명               # 파일이 실행 가능 상태이면 참

## 논리 연산
# 조건1 -a 조건2         # AND
# 조건1 -o 조건2         # OR
# 조건1 && 조건2         # 양쪽 다 성립
# 조건1 || 조건2         # 한쪽 또는 양쪽다 성립
# !조건                  # 조건이 성립하지 않음
# true                   # 조건이 언제나 성립
# false                  # 조건이 언제나 성립하지 않음

## 조건문 문법
# 기본 if/else 구문
# if [ 조건 ]
# then
#   명령문
# else
#   명령문
# fi

if [[ $1 != $2 || -z $2 ]]
then
    echo "입력한 값이 일치하지 않습니다."
#    exit
fi

# 기본 if 구문 (한 라인에 작성하는 방법)
# if [ 조건 ]; then 명령문; fi
if [[ -z $1 ]]; then echo "인수를 입력하시오"; fi

## [ ] 앞, 뒤에는 반드시 공백이 있어야 한다.
## []에서 &&, ||, ,, > 연산자들이 에러가 나는 경우에는 [[ ]]를 사용하면
## 정상 작동하는 경우가 있다.

## 반복문 문법
# 기본 for 구문
# for 변수 in 변수1 변수2 ...
# do
#   명령문
# done

for database in $(ls)
do
    echo ${database[*]}
done

# 기본 while 구문
# do
#   명령문
# done
lists=$(ls)
num=${#lists[@]}
index=0
while [ $num -ge 0 ]
do
    echo ${lists[$index]}
    index=`expr $index + 1`
    num=`expr $num - $index`
done