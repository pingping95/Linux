filename="ETC"`date +%F__%T`

echo "********************************" >> /chk/${filename}.txt 
echo "6.1 경고 메시지 설정 " >> /chk/${filename}.txt
echo "********************************" >> /chk/${filename}.txt 

echo "TELNET****" >> /chk/${filename}.txt 
cat /etc/issue   >> /chk/${filename}.txt 
echo "FTP****" >> /chk/${filename}.txt 
cat /etc/banners/ftp.msg   >> /chk/${filename}.txt 
echo "SSH****" >> /chk/${filename}.txt 
cat /etc/ssh/sshd_config   >> /chk/${filename}.txt 
echo "********************************" >> /chk/${filename}.txt 





echo " " >> /chk/${filename}.txt 
echo "********************************" >> /chk/${filename}.txt 
echo "6.2 exrc 파일 설정" >> /chk/${filename}.txt
echo "****************** **************" >> /chk/${filename}.txt 
'cat /.exrc | grep !'   >> /chk/${filename}.txt 


echo " " >> /chk/${filename}.txt 
echo "********************************" >> /chk/${filename}.txt 
echo "6.3 스케줄링 미사용 설정" >> /chk/${filename}.txt
echo "****************** **************" >> /chk/${filename}.txt 



echo " " >> /chk/${filename}.txt 
echo "********************************" >> /chk/${filename}.txt 
echo "6.4 패치 확인 " >> /chk/${filename}.txt
echo "****************** **************" >> /chk/${filename}.txt


rpm -qa | cut -f2  >>  /chk/${filename}.txt

