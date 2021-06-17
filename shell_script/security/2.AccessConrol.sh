filename="accesscontrol"`date +%F__%T`

echo " " >>/chk/${filename}.txt
echo "********************************"
echo "*** 2.1 xinetd.conf 권한설정 644인경우 정상"  >>  /chk/${filename}.txt
echo "********************************"

file1=`ls -l /etc/xinetd.conf | awk '{print $1}'`
if [ -f /etc/xinetd.conf];then 
   echo "파일 존재"  >>  /chk/${filename}.txt
 
	if [ $file1 = "-rw-r--r--." ];then
	  echo "/etc/xinetd 파일권한 정상" >> /chk/${filename}.txt
	else
	  echo "/etc/xinetd  파일권한 취약 (644 설정필요)" >> /chk/${filename}.txt
	fi
else 
   echo "파일 미존재"   >>  /chk/${filename}.txt
fi


echo " "  >>/chk/${filename}.txt
echo "***************************" >>/chk/${filename}.txt
echo "*** 2.2 su 명령 제한" >> /chk/${filename}.txt
echo "***************************" >>/chk/${filename}.txt
NUM=`grep pam_wheel.so /etc/pam.d/su | grep -v '^#' | wc -l`
if [ $NUM -gt 0 ] ; then
 echo "su 명령어를 특정 그룹에 속한 사용자만 사용하도록 제한" >> /chk/${filename}.txt
else
 echo "su 명령어를 모든 사용자가 사용하도록 설정되어 있는 경우 입니다." >> /chk/${filename}.txt
fi

echo " "  >>/chk/${filename}.txt
echo "***************************" >>/chk/${filename}.txt
echo "*** 2.3 암호화된 원격 접속 설정" >> /chk/${filename}.txt
echo "***  active상태 확인 = active 정상" >> /chk/${filename}.txt

systemctl status sshd >> /chk/${filename}.txt


echo " "  >>/chk/${filename}.txt
echo "***************************" >>/chk/${filename}.txt
echo "*** 2.4 원격 ROOT 접속 설정 " >> /chk/${filename}.txt
echo "***************************" >>/chk/${filename}.txt

echo "/etc/pam.d/login 파일 설정 중 ( auth required /lib/security/pam_securetty.so )항목을 확인하고 주석이 없는 상태가 맞는지 확인한다." >> /chk/${filename}.txt

echo "#이 붙어있는지 확인한다." >>/chk/${filename}.txt
cat /etc/pam.d/login | grep "auth       required" >> /chk/${filename}.txt

echo " "  >>/chk/${filename}.txt
echo "***************************" >>/chk/${filename}.txt
echo "*** 2.5 Time OUT 설정" >> /chk/${filename}.txt
echo "***************************" >>/chk/${filename}.txt
cat /etc/profile | grep TMOUT | awk -F[=] '{print $2}' 
if [ $? -eq 0 ];then
  TMOUT=`cat /etc/profile | grep TMOUT | awk -F[=] '{print $2}'`
  if [ $TMOUT -le 300 -a $TMOUT -ge 10 ];then
    echo "${TMOUT} 초 - 터미널 타임아웃 정상" >> /chk/${filename}.txt
  else
    echo "${TMOUT} 초 - 터미널 타임아웃 취약 (300 초 미만 권장 설정)" >> /chk/${filename}.txt
  fi
else
  echo "터미널 타임아웃 비설정 (300  초 미만 권장 설정)" >> /chk/${filename}.txt 
fi
echo "***************************" >>/chk/${filename}.txt
echo "***************************" >>/chk/${filename}.txt
