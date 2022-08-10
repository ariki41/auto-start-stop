#!/bin/bash

#録画予約情報取得
curl -s "http://localhost:8888/api/reserves?offset=0&limit=24&isHalfWidth=true" | jq -r ".reserves[] | .startAt" > time.txt


#予約した一番早くくる番組の時間を取得
STARTTIME=`head -n 1 ./time.txt`
STARTTIME=${STARTTIME:0:10}


#wakealarmをいったん0で上書き(すでにセットされていると上書きできない)
echo 0 > /sys/class/rtc/rtc0/wakealarm

#予約時間の10分前の時間をセット
echo `expr $STARTTIME - 600` > /sys/class/rtc/rtc0/wakealarm

