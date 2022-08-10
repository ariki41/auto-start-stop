#!/bin/bash

PWD="/home/ariki/auto-start-stop"

source ${PWD}/conf

function log(){
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] $@" | tee -a ${LOGFILE}
}

function filesize(){
	OLDFILESIZE=`cat ${PWD}/old_filesize`
	NEWFILESIZE=`du -s /mnt/data 2> /dev/null | grep -o '[0-9]*'`
	
	log "OLD FILESIZE: ${OLDFILESIZE}"
	log "NEW FILESIZE: ${NEWFILESIZE}"

	FLAG=0
	DIFF=$(($NEWFILESIZE - $OLDFILESIZE))
	DIFF=`echo $DIFF | sed 's/^-//'`

	if [ $DIFF -gt 1000 ]; then
		log "File size chenged by 1000 bytes"
		FLAG=1
	fi


	echo $NEWFILESIZE > ${PWD}/old_filesize

	return $FLAG
}

function active_user(){
	LOGINUSERNUM=`curl -sA "user_info" -u "${KEY}" ${URL} | jq ".ocs.data.activeUsers.last5minutes"`

	log "Nextcloud 5m Login User Num: ${LOGINUSERNUM}"

	FLAG=0
	if [ $LOGINUSERNUM -ge 2 ]; then
		FLAG=1
	fi

	return $FLAG
}


filesize
FILESIZE=$?

active_user
ACTIVEUSER=$?

if [ `who | wc -l` -eq 0 ]; then
	if [ `cut -d "." -f 1 /proc/uptime` -ge 600 ]; then
		if [ $ACTIVEUSER -eq 0 ]; then
			if [ $FILESIZE -eq 0 ]; then
				${PWD}/sql.sh
				sleep 10
				log "shutdown now"
				sudo shutdown -h now
			fi
		fi
	else
		log "Launched within 10 minutes"
	fi
else
	log "SSH login now"
fi

