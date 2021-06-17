#!/bin/bash


DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=4b7f5ccd2019620203c68c6806a3955c DD_SITE="datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"
sleep 3 


DD_HOST="CCSIN-MUMBAI-PRD-B-USERLINK-02"
sed -i "s/# hostname: <HOSTNAME_NAME>/hostname: ${DD_HOST}/" /etc/datadog-agent/datadog.yaml
sleep 2
systemctl restart datadog-agent


DD_HOST="CCSIN-MUMBAI-PRD-A-CPW-01"
sed -i "s/# hostname: <HOSTNAME_NAME>/hostname: ${DD_HOST}/" /etc/datadog-agent/datadog.yaml
sleep 2
systemctl restart datadog-agent


DD_HOST="CCSIN-MUMBAI-PRD-B-CPW-02"
sed -i "s/# hostname: <HOSTNAME_NAME>/hostname: ${DD_HOST}/" /etc/datadog-agent/datadog.yaml
sleep 2
systemctl restart datadog-agent