filename="servicesecure"`date +%F__%T`

echo "********************************" >> /chk/${filename}.txt 
echo "4.2 NPS 공유 설정 " >> /chk/${filename}.txt
echo "********************************" >> /chk/${filename}.txt 

TARGET1=/etc/exports
CHECK1=$(ps -ef | egrep 'nfsd|statd|mountd' | grep -v pts)
if [[ -z $CHECK1 ]]; then
        echo -e "=> 양호 \nnfs 서비스 중지 상태"    >> /chk/${filename}.txt
else
        echo -e "=> 점검 \nnfs 서비스 실행 상태\nnfs 미사용 서버일 경우 서비스 종료"  >> /chk/${filename}.txt
        cat $TARGET1
fi





echo "  " >> /chk/${filename}.txt 
echo "********************************" >> /chk/${filename}.txt 
echo "4.3 FTP 설정 " >> /chk/${filename}.txt
echo "********************************" >> /chk/${filename}.txt 


if test -f /etc/vsftpd/vsftpd.conf
	then
		if [ "`cat /etc/vsftpd/vsftpd.conf | grep anonymous_enable | awk -F= '{print $2}'`" = NO ]
			then
				echo "[안전] FTP에 익명 접속이 불가능합니다" >> /chk/${filename}.txt 
			else
				echo " [취약] FTP에 익명 접속이 가능합니다" >>/chk/${filename}.txt 
		fi
	else
		echo "FTP 서비스가 설치되어 있지 않습니다" >> /chk/${filename}.txt 
fi


echo "  " >> /chk/${filename}.txt 
echo "********************************" >> /chk/${filename}.txt 
echo "4.4 서비스 배너 점검 " >> /chk/${filename}.txt
echo "********************************" >> /chk/${filename}.txt 

CHECK1=$(find /etc/ -name issue -o -name proftpd.conf -o -name vsftpd.conf -o -name main.cf -o -name named.conf | xargs egrep -i 'release|message|version|banner' | grep -v '#')
if [[ -z $CHECK1 ]]; then
        echo -e " 양호 message, version, banner 비공개 설정" >> /chk/${filename}.txt
else
        echo -e " 취약 - message, version, banner 비공개 설정 시 양호\n$CHECK1"  >> /chk/${filename}.txt
fi

echo "  " >> /chk/${filename}.txt 
echo "********************************" >> /chk/${filename}.txt 
echo "4.5 SNMP community string 값 설정  " >> /chk/${filename}.txt
echo "********************************" >> /chk/${filename}.txt 

echo "점검 : Community String이 public, private 이 아니면 양호"

TARGET1=/etc/snmp/snmpd.conf
CHECK1=$(ps -ef | grep snmp | grep -v pts)
if [[ -n $CHECK1 ]]; then
        CHECK2=$(egrep 'public|private' $TARGET1 | grep -v '#' | grep -v pts)
        if [[ -e $TARGET1 ]]; then
                if [[ -z $CHECK2 ]];then
                        echo -e "=> 양호 \nsnmpd 서비스 실행 상태\npublic, private community 없음"  >> /chk/${filename}.txt

                else
                        echo -e "=> 취약 \nsnmpd 서비스 실행 상태\npublic, private community 제거 시 양호"  >> /chk/${filename}.txt

                fi
        else
                echo -e "=> 점검 \nsnmpd 서비스 실행 상태\n/etc/snmp/snmpd.conf 파일 없음"  >> /chk/${filename}.txt

        fi
else
        echo -e "=> 양호 \nsnmpd 서비스 중지 상태"  >> /chk/${filename}.txt
fi


