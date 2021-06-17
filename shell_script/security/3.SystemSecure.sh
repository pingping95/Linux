filename="system_${filename}"`date +%F__%T`


echo "****************************" >>  /chk/${filename}.txt
echo "3.1 환경설정 644 이하 정상"  >>  /chk/${filename}.txt
echo ".profile, .login, .tschrc, .kshrc, .history, sh_histroy 파일 미존재" >>  /chk/${filename}.txt
echo "****************************" >>  /chk/${filename}.txt

file1=`ls -l /etc/profile | awk '{print $1}' | grep "...-.--.--" | wc -l`
file2=`ls -l $HOME/.profile | awk '{print $1}' | grep "...-.--.--" | wc -l`
file3=`ls -l $HOME/.login | awk '{print $1}' | grep "...-.--.--" | wc -l`
file4=`ls -l $HOME/.cshrc | awk '{print $1}' | grep "...-.--.--" | wc -l`
file5=`ls -l $HOME/.tschrc | awk '{print $1}' | grep "...-.--.--" | wc -l`
file6=`ls -l $HOME/.kshrc | awk '{print $1}' | grep "...-.--.--" | wc -l`
file7=`ls -l $HOME/.bashrc | awk '{print $1}' | grep "...-.--.--" | wc -l`
file8=`ls -l $HOME/.bash_profile | awk '{print $1}' | grep "...-.--.--" | wc -l`
file9=`ls -l $HOME/.history | awk '{print $1}' | grep "...-.--.--" | wc -l`
file99=`ls -l $HOME/.sh_history | awk '{print $1}' | grep "...-.--.--" | wc -l`

file10=`ls -l /etc/hosts | awk '{print $1}' | grep "...-.--.--" | wc -l`
file11=`ls -l /etc/hosts | awk '{print $3}' | grep "root" | wc -l`

if [ $file1 -eq 1 ];then
  echo "/etc/profile 파일권한 정상" >> /chk/${filename}.txt
else
  echo "/etc/profile  파일권한 취약 (640 이하 설정필요)" >> /chk/${filename}.txt
fi


if [ $file4 -eq 1 ];then
  echo "/cshrc  파일권한 정상" >> /chk/${filename}.txt
else
  echo "/cshrc  파일권한 취약 (640 이하 설정필요)" >> /chk/${filename}.txt
fi


if [ $file7 -eq 1 ];then
  echo "/bashrc 파일권한 정상" >> /chk/${filename}.txt
else
  echo "/bashrc  파일권한 취약 (640 이하 설정필요)" >> /chk/${filename}.txt
fi


if [ $file8 -eq 1 ];then
  echo "/bashrc_profile 파일권한 정상" >> /chk/${filename}.txt
else
  echo "/bashrc_profile  파일권한 취약 (640 이하 설정필요)" >> /chk/${filename}.txt
fi


echo " " >>  /chk/${filename}.txt
echo "****************************" >>  /chk/${filename}.txt
echo "3.3 HOST 파일 설정(640 이하 및 root 서유)"  >>  /chk/${filename}.txt
echo "****************************" >>  /chk/${filename}.txt
if [ $file10 -eq 1 ];then
  echo "/etc/hosts  파일권한 정상" >> /chk/${filename}.txt
else
  echo "/etc/hosts  파일권한 취약 (640 이하 설정)" >> /chk/${filename}.txt
fi


if [ $file11 -eq 1 ];then
  echo "/etc/hosts  파일소유 정상" >> /chk/${filename}.txt
else
  echo "/etc/hosts  파일소유 취약 (ROOT 아님)" >> /chk/${filename}.txt
fi

echo " " >>  /chk/${filename}.txt
echo "****************************" >>  /chk/${filename}.txt
echo "**** 3.4 부팅스크립트 점검" >>  /chk/${filename}.txt
echo "****************************" >>  /chk/${filename}.txt

filex=`ls -l /etc/init.d/netconsole | awk '{print $1}'`
filexx=`ls -l /etc/init.d/network | awk '{print $1}'`
if [ $filex = "-rwxr-xr--." ];then
  echo "/etc/init.d 파일권한 정상" >> /chk/${filename}.txt
else
  echo "/etc/init.d  파일권한 취약 (754 설정필요)" >> /chk/${filename}.txt
fi


if [ $filexx = "-rwxr-xr--." ];then
  echo "/etc/init.d 파일권한 정상" >> /chk/${filename}.txt
else
  echo "/etc/init.d  파일권한 취약 (754 설정필요)" >> /chk/${filename}.txt
fi

echo " " >>  /chk/${filename}.txt
echo "****************************" >>  /chk/${filename}.txt
echo "**** 3.5 PATH 설정" >>  /chk/${filename}.txt
echo "****************************" >>  /chk/${filename}.txt

CHECK1=$(/usr/bin/printenv | grep PATH | grep '\:\.\:')
if [[ -z $CHECK1 ]]; then
    echo -e "=> 양호 \npath 경로에 . 없음" >>  /chk/${filename}.txt
else
    echo -e "=> 취약 \npath 경로에 . 제거 시 양호" >> /chk/${filename}.txt
fi


echo " " >>  /chk/${filename}.txt
echo "****************************" >>  /chk/${filename}.txt
echo "**** 3.6 UMASK 설정" >>  /chk/${filename}.txt
echo "****************************" >>  /chk/${filename}.txt

echo "점검 : umask 값이 022, 027 이면 양호"
CHECK1=$(egrep 'umask 022|umask 027' /etc/profile /etc/bashrc | wc -l)
if [[ 2 -eq $CHECK1 ]]; then
    echo -e "=> 양호 \n/etc/profile, /etc/bashrc 파일에 umask 022 설정 확인" >>  /chk/${filename}.txt
else
    echo -e "=> 취약 \n/etc/profile, /etc/bashrc 파일에 umask 022 설정 시 양호" >>  /chk/${filename}.txt
fi






echo " " >>  /chk/${filename}.txt
echo "****************************" >>  /chk/${filename}.txt
echo "**** 3.7 SUID/SGID의 설정" >>  /chk/${filename}.txt
echo "SetUID,SetGID 생성되는 파일 점검대상" >>  /chk/${filename}.txt
echo "****************************" >>  /chk/${filename}.txt
SF="/chk/3.7.SetUID_${filename}.txt"
SG="/chk/3.7.SetGID_${filename}.txt"

find / -user root -perm -4000 2>/dev/null > $SF 
find / -user root -perm -2000 2>/dev/null > $SG 

echo " " >>  /chk/${filename}.txt
echo "****************************" >>  /chk/${filename}.txt
echo "**** 3.8 홈디렉토리 설정" >>  /chk/${filename}.txt
echo "****************************" >>  /chk/${filename}.txt
echo "@@"
filett=`ls -l /home | awk '{print $1}'`
echo $filett
if [ $filett="-rwxr-xr-x."];then
  echo "/home 파일권한 정상" >> /chk/${filename}.txt
else
  echo "/home  파일권한 취약 (755 설정필요)" >> /chk/${filename}.txt
fi



echo " " >>  /chk/${filename}.txt
echo "****************************" >>  /chk/${filename}.txt
echo "**** 3.9 history file 권한설정" >>  /chk/${filename}.txt
echo "****************************" >>  /chk/${filename}.txt

history1=`ls -l $HOME/.history | awk '{print $1}'`
history2=`ls -l $HOME/.sh_history | awk '{print $1}'`
history3=`ls -l $HOME/.bash_history | awk '{print $1}'`


if [ $history1="-rw-------." ];then
  echo "/HOME/.history 파일권한 정상" >> /chk/${filename}.txt
else
  echo "/HOME/.history 파일권한 취약 (600 설정요망)" >> /chk/${filename}.txt
fi


if [ $history2="-rw-------." ];then
  echo "/HOME/.sh_history 파일권한 정상" >> /chk/${filename}.txt
else
  echo "/HOME/.sh_history 파일권한 취약 (600 설정요망)" >> /chk/${filename}.txt
fi

if [ $history3="-rw-------." ];then
  echo "/HOME/bash_history 파일권한 정상" >> /chk/${filename}.txt
else
  echo "/HOME/bash_history 파일권한 취약 (600 설정요망)" >> /chk/${filename}.txt
fi

echo " " >>  /chk/${filename}.txt
echo "****************************" >>  /chk/${filename}.txt
echo "**** 3.10 /dev에 존재하지 않는 파일 점검" >>  /chk/${filename}.txt
echo "****************************" >>  /chk/${filename}.txt

echo
find /dev -type f -exec ls -l {} \; | awk '{print $1, $8}' >>  /chk/${filename}.txt

