#!/bin/bash

UPTIME=`uptime -s`
NOW=`date +"%Y-%m-%d %H:%M:%S"`

PWD="/home/ariki/auto-start-stop"

source ${PWD}/conf

SQL="
SET @AFTER = UNIX_TIMESTAMP(SUBTIME('${UPTIME}', '09:00:00'));
SET @BEFORE = UNIX_TIMESTAMP(SUBTIME('${NOW}', '09:00:00'));

WITH recursive upd(depth, id, parent, path) AS (
	SELECT 0, fileid, parent, path
	FROM  oc_filecache
	WHERE (mtime BETWEEN @AFTER AND @BEFORE) AND (mimetype = 2) AND (parent = 231)
	UNION
	SELECT upd.depth + 1, filechace.fileid, filechace.parent, filechace.path
	FROM oc_filecache AS filechace, upd
	WHERE filechace.parent = upd.id AND (mtime BETWEEN @AFTER AND @BEFORE) AND (mimetype = 2)
)

SELECT * FROM upd WHERE depth > 0;"

docker exec nextcloud_db_1 mysql -u ${DBUSER} -p${PASS} nextcloud -e "${SQL}" > ${PWD}/data
sed -i -e '1d' ${PWD}/data

scp -i ${PWD}/scp ${PWD}/data ariki@192.168.2.11:/home/ariki/discord_bot
