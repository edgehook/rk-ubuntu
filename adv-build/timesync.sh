#!/bin/bash
FLAG=`grep -o "timesync.sh" /etc/crontab  | wc -l`
if [ $FLAG == "0" ];then
    echo "0 */8 * * * root /usr/local/bin/timesync.sh" >> /etc/crontab
fi
 
