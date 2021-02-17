#!/bin/sh

if [ $(systemctl status mysql.service|grep -c "active (running)") -eq 1 ];
then
	if [ $(systemctl status keepalived.service|grep -c "active (running)") -eq 0 ];
	then
		systemctl start keepalived
	fi
fi
