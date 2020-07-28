#!/bin/bash
#If the installer fails, change #!/bin/bash to #!/bin/sh

printf "Installing MD5CheckSum Extension...\n"

DEFINITION_PATH="/var/db/newrelic-infra/custom-integrations"
CONFIG_PATH="/etc/newrelic-infra/integrations.d"
SERVICE='newrelic-infra'

#check os release
if [ -f /etc/os-release ]; then #amazon/redhat/fedora check
  . /etc/os-release
  OS=$NAME
  VERSION=$VERSION_ID
  printf "OS Name: $OS\n"
  printf "Version: $VERSION\n"
elif [ -f /etc/lsb-release ]; then #ubuntu/debian check
  . /etc/lsb-release
  OS=$DISTRIB_ID
  VERSION=$DISTRIB_RELEASE
  printf "OS Name: $OS\n"
  printf "Version: $VERSION\n"
fi

#check init system
initCmd=`ps -p 1 | grep init | awk '{print $4}'`
if [ "$initCmd" == "init" ]; then
  SYSCMD='upstart'
fi
sysdCmd=`ps -p 1 | grep systemd | awk '{print $4}'`
if [ "$sysdCmd" == "systemd" ]; then
  SYSCMD='systemd'
fi

#copy files [add more as needed]
printf "Copying files...\n"
cp solution/md5.sh $DEFINITION_PATH
cp solution/md5.txt $DEFINITION_PATH
cp solution/md5-definition.yml $DEFINITION_PATH
cp solution/md5-template.json $DEFINITION_PATH
cp solution/md5-config.yml $CONFIG_PATH

printf "Script complete. Restarting Infrastructure Agent...\n"
if [ $SYSCMD == "systemd" ]; then
  systemctl restart $SERVICE
elif [ $SYSCMD == "upstart" ]; then
  initctl restart $SERVICE
fi
