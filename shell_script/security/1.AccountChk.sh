filename="account"`date +%F__%T`
 

# 비 root 계정 중에서 UID 0 찾기

echo "********************************" >> /chk/${filename}.txt 
echo "1.1 비 root 계정 중에서 UID 0" >> /chk/${filename}.txt
echo "********************************" >> /chk/${filename}.txt 

UIDS=`awk -F[:] 'NR!=1{print $3}' /etc/passwd`
flag=0
for i in $UIDS
do
  if [ $i = 0 ];then
    echo "비 root 계정 중에서 UID 0 존재 - 취약" >> /chk/${filename}.txt
  else
    flag=1
  fi
done
if [ $flag = 1 ];then
  echo "비 root 계정 중에서 UID 0 존재하지 않음 - 정상" >> /chk/${filename}.txt
fi

echo " "   >> /chk/${filename}.txt
echo "***************************"  >> /chk/${filename}.txt 
echo "*** 1.2 로그인 Shell 제한" >> /chk/${filename}.txt
echo "***************************"  >> /chk/${filename}.txt

echo "점검 : 로그인이 필요하지 않은 시스템 계정에 /bin/false(nologin) 셸이 부여되어 있으면 양호"
TARGET1=/etc/passwd
CHECK1=$(cat $TARGET1 | egrep -v '/bin/false|/sbin/nologin')
echo -e "=> 로그인 불필요 계정 셸 변경(usermod -s /bin/false 계정명)\n$CHECK1"


echo " "   >> /chk/${filename}.txt
echo "***************************"  >> /chk/${filename}.txt 
echo "*** 1.4 패스워드 파일 권한 설정" >> /chk/${filename}.txt
echo "***************************"  >> /chk/${filename}.txt
file1=`ls -l /etc/passwd | awk '{print $1}'`
file2=`ls -l /etc/shadow | awk '{print $1}'`


if [ $file1 = "-rw-r--r--." ];then
  echo "/etc/passwd 파일권한 정상" >> /chk/${filename}.txt
else
  echo "/etc/passwd 파일권한 취약 (644 설정요망)" >> /chk/${filename}.txt
fi

if [ $file2 = "----------." ];then
  echo "/etc/shadow 파일권한 정상" >> /chk/${filename}.txt
else
  echo "/etc/shadow 파일권한 취약 (000 설정)" >> /chk/${filename}.txt
fi


passmax=`cat /etc/login.defs | grep PASS_MAX_DAYS | grep -v ^# | awk '{print $2}'`
passmin=`cat /etc/login.defs | grep PASS_MIN_DAYS | grep -v ^# | awk '{print $2}'`
passlen=`cat /etc/login.defs | grep PASS_MIN_LEN | grep -v ^# | awk '{print $2}'`
passage=`cat /etc/login.defs | grep PASS_WARN_AGE | grep -v ^# | awk '{print $2}'`

echo " "  >> /chk/${filename}.txt
echo "***************************"  >> /chk/${filename}.txt 
echo "*** 1.5 패스워드 최소길이 설정" >> /chk/${filename}.txt
echo "***************************"  >> /chk/${filename}.txt

file1=`ls -l /etc/passwd | awk '{print $1}'`
echo "1.5  최소암호길이 " >> /chk/${filename}.txt
if [ $passlen -ge 8 ];then
  echo "${passlen} 자리 - 최소 암호 길이 정상" >> /chk/${filename}.txt
else
  echo "${passlen} 자리 - 최소 암호 길이 취약 (8자리 이상 설정)" >> /chk/${filename}.txt
fi

echo " "  >> /chk/${filename}.txt
echo "***************************"  >> /chk/${filename}.txt 
echo "*** 1.7 계정점금 임계값 설정" >> /chk/${filename}.txt
echo "*** 암호 LOCK (4회까지 허용)" >> /chk/${filename}.txt
echo "***************************"  >> /chk/${filename}.txt
cat /etc/pam.d/system-auth | grep "auth        required      pam_tally2.so" >> /chk/${filename}.txt

cat /etc/pam.d/system-auth | grep "auth        required      pam_tally2.so" | awk '{print $4}' >> /chk/${filename}.txt
echo "입니다. " >> /chk/${filename}.txt

echo " "  >> /chk/${filename}.txt
echo "***************************"  >> /chk/${filename}.txt 
echo "*** 1.8 패스워드 최대 사용기간 설정" >> /chk/${filename}.txt
echo "***************************"  >> /chk/${filename}.txt

echo "1.8 암호 수명(91일 설정) " >> /chk/${filename}.txt
if [ $passmax -eq 91 ];then
 echo "${passmax} 일 - 암호 수명 정상" >> /chk/${filename}.txt
else
 echo "${passmax} 일 - 암호 수명 취약 (90 일 설정)" >> /chk/${filename}.txt
fi


echo " "  >> /chk/${filename}.txt
echo "***************************"  >> /chk/${filename}.txt 
echo "*** 1.9 최근 패스워드 기억  설정" >> /chk/${filename}.txt
echo "*** 암호 최근 기억 설정5이상인지 확인" >> /chk/${filename}.txt
echo "***************************"  >> /chk/${filename}.txt
cat /etc/pam.d/system-auth | grep "password    sufficient    pam_unix.so" >> /chk/${filename}.txt
echo "기억설정 일수는? " >> /chk/${filename}.txt
cat /etc/pam.d/system-auth | grep "password    sufficient    pam_unix.so" | awk '{print $9}'>> /chk/${filename}.txt 

echo "입니다. " >> /chk/${filename}.txt

