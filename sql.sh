#!/bin/bash

UPTIME=`uptime -s`
NOW=`date +"%Y-%m-%d %H:%M:%S"`

PWD="/home/ariki/auto-start-stop"

source ${PWD}/conf

SQL="
SET @AFTER = UNIX_TIMESTAMP('${UPTIME}');
SET @BEFORE = UNIX_TIMESTAMP('${NOW}');

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

docker exec nextcloud_db_1 mariadb -u ${DBUSER} -p${PASS} nextcloud -e "${SQL}" > ${PWD}/data
sed -i -e '1d' ${PWD}/data

scp -i /home/ariki/.ssh/yuika_key ${PWD}/data ariki@yuika:/home/ariki/discord_bot_hazuki
