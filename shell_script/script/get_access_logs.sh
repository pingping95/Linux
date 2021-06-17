#!/bin/bash

# README
echo "이 스크립트는 ELB Access Logs를 시간대별로 Download 받은 후 추출하여 하나의 access_logs.txt 파일로
생성하는 Shell Script입니다.

[전제 조건]
1. ~/.aws/credentials에 Profile 등록되어 있어야 함 (자격 증명)
2. IAM User가 s3에 대한 권한이 있어야 함 (Admin 권한일 경우 상관 X)
3. Region 이름
4. Access Log가 보관 중인 Bucket Name
( aws s3 ls --profile {profile name} )
5. Access Logs를 확인할 날짜 (UTC 기준이며, UST = KST - 9)
6. 시간대 ( 00 = 00:00 ~ 00:59까지의 Log를 Download하며, 01 = 01 : 00 ~ 01 : 59까지의 Log를 다운로드
시간대는 여러 시간 대역을 설정할 수 있으며 00, 01, 02, 03으로 설정하면 00:00 ~ 03:59 까지의 Log 파일을 다운로드 한 후 하나의 txt 파일로 생성
"

sleep 3

# Get variables from user

# Profile Name
echo -e "Profile Name?   ex) default, eks-user, .."
echo -n "Profile Name: "
read -r profile_name

profile_in_file=$(grep -v access ~/.aws/credentials | grep -E "\[${profile_name}\]")

if [[ -n $profile_in_file ]]
then
    echo -e "
Profile name '${profile_name}' exists
"
else
    echo "
Profile name ${profile_name} do not exists!
Check ~/.aws/credentials file
"
    exit 0
fi

# Region
echo -e "
Region Name?     ex) sa-east-1, ap-northeast-2, .."
echo -n "Region Name: "
read region_name


# Bucket 
echo -e "
Bucket Name ?     ex) my-prd-lb-accesslog, .."
echo -n "Bucket Name: "
read bucket_name

# Check s3 buckets
buckets=$(aws s3 ls --profile "${profile_name}" | awk '{print $3}')

bucket_check=$(echo "$buckets" | grep "${bucket_name}")

if [[ -n "${bucket_check}" ]]
then
    echo "Bucket '${bucket_check}' exists!"
else
    echo -e "Bucket '${bucket_name}' do not exists!

Check Profile ${profile_name}\`s Buckets. 
ex) aws s3 ls --profile ${profile_name}"
    exit 0
fi

# Account Number
account_number=$(aws sts get-caller-identity --output text --query 'Account' --profile "${profile_name}")

# ELB Name
echo -e "
ELB Name ?     ex) hello-apne2-prd-nlb, .. "
echo -n "ELB Name: "
read -r elb_name

# Date
echo -e "
Date?      ex) 2021-06-14, 2021-11-10"
echo -n "Date: "
read -r init_date

year=$(echo "$init_date" | awk -F "-" '{print $1}')
month=$(echo "$init_date" | awk -F "-" '{print $2}')
day=$(echo "$init_date" | awk -F "-" '{print $3}')

date=$(echo "$init_date" | awk -F "-" '{print $1$2$3}')

echo ""

# Time (Array)
time_array=()
while IFS= read -r -p "Time (UTC 기준으로 기입할 것, Loop 종료 : 바로 Enter 키)
ex) 00 : 00:00 ~ 00:59, 14 : 14:00 ~ 14:59
: " line; do
    [[ $line ]] || break  # break if line is empty
    time_array+=("$line")
done

echo "
Times: "

for (( i=0; i<${#time_array[@]}; i++ )); do
    echo "${time_array[i]}:00 ~ ${time_array[i]}:59"
done


s3_path=${bucket_name}/AWSLogs/${account_number}/elasticloadbalancing/${region_name}/${year}/${month}/${day}

for (( i=0; i<${#time_array[@]}; i++ )); do
    sleep 2
    filtering="*${elb_name}*${date}T${time_array[i]}*"
    aws s3 cp --profile "${profile_name}" s3://"${s3_path}" . --recursive --exclude "*" --include "${filtering}" && echo "Success Download ${time_array[i]}" || echo "Failed Download ${time_array[i]}"
done

sleep 5

# Unzip files
gzip -d *.gz && rm -rf *.gz


# .txt 파일 저장
cat *.log > "${elb_name}-access_logs-${month}-${day}.txt" && rm -rf *.log


echo "
##############################################"
echo "               Finished"
echo "###############################################"

