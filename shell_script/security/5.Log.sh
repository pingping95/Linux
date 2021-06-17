filename="Log"`date +%F__%T`

echo "********************************" >> /chk/${filename}.txt 
echo "5.1 로그기록  설정 " >> /chk/${filename}.txt
echo "********************************" >> /chk/${filename}.txt 

TARGET1=/etc/rsyslog.conf
CHECK1=$(ps -ef | grep rsyslog | grep -v pts)
if [[ -n $CHECK1 ]]; then
        CHECK2=$(grep -v '#' /etc/rsyslog.conf | egrep 'info|authpriv|maillog|cron|alert|emerg' | wc -l)
        if [[ 6 -eq $CHECK2 ]]; then
                echo -e " 양호 rsyslog 서비스 실행 상태\n6개 로그 설정 확인" >>  /chk/${filename}.txt
        else
                echo -e " 취약 rsyslog 서비스 실행 상태\n- 아래 로그 설정 시 양호\n\n- CentOS 6\n*.info;mail.none;authpriv.none;cron.none                /var/log/messages\n\
authpriv.*                                              /var/log/secure\nmail.*                                                  -/var/log/maillog\n\
cron.*                                                  /var/log/cron\n*.alert                                                  /var/log/messages\n\
*.emerg                                                 *\n\n- CentOS 8\n*.info;mail.none;authpriv.none;cron.none                /var/log/messages\n\
authpriv.*                                              /var/log/secure\nmail.*                                                  -/var/log/maillog\n\
cron.*                                                  /var/log/cron\n*.alert                                                  /var/log/messages\n\
*.emerg                                                 :omusrmsg:*" >> /chk/${filename}.txt
        fi
else
        echo -e " 취약 \nrsyslog 중지 상태" >>  /chk/${filename}.txt
fi



echo "********************************" >> /chk/${filename}.txt 
echo "5.2 SU 로그 설정  " >> /chk/${filename}.txt
echo "********************************" >> /chk/${filename}.txt 
echo "점검 : sulog 설정이 되어 있는 경우 양호">> /chk/${filename}.txt
echo -e "=> 양호\n/var/log/secure 파일에 기록">> /chk/${filename}.txt
TARGET1=/etc/login.defs
TARGET2=/etc/rsyslog.conf
CHECK1=$(grep sulog $TARGET1 | grep -v '#')
CHECK2=$(grep sulog $TARGET2 | grep -v '#')
if [[ -n $CHECK1 && -n $CHECK2 ]]; then
    echo -e "=> 양호 \nsulog 로그 설정 확인"   >> /chk/${filename}.txt
else
    echo -e "=> 취약 \n- 아래 설정 추가 시 양호\n/etc/login.defs : SULOG_FILE /var/log/sulog\n/etc/rsyslog.conf : auth.info/var/log/sulog" >> /chk/${filename}.txt

fi

echo "********************************" >> /chk/${filename}.txt 
echo "5.3 LAST LOG  로그 설정  " >> /chk/${filename}.txt
echo "********************************" >> /chk/${filename}.txt 

last   >> /chk/${filename}.txt 

echo "********************************" >> /chk/${filename}.txt 

