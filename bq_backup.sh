#!/bin/bash

# Stackdriver Loggingにログを出力する際のLOG_NAME
STL_LOG_NAME=bq_backup

#バックアップ対象データセット
#ex) project_id.dataset_name
BK_FROM_DS=$1

#バックアップ先データセット
#ex) project_id.dataset_name
BK_TO_DS=$2

#対象テーブル
#tbl_a,tbl_b
TRGT_TBLS=$3

#TIMESTAMP
TIMESTAMP=$(date '+%Y%m%d%H%M%S')

gcloud logging write $STL_LOG_NAME  "BEGIN BACKUP"

for TRGT_TBL in $(echo $TRGT_TBLS | sed -e "s/,/ /g")
do
  BK_FROM=${BK_FROM_DS}.${TRGT_TBL}
  BK_TO=${BK_TO_DS}.${TRGT_TBL}_${TIMESTAMP}
  MSG=$(bq -q cp -f ${BK_FROM} ${BK_TO} 2>&1 >/dev/null)
  STATUS=$?
  if [ $STATUS == 0 ]; then
    gcloud logging write $STL_LOG_NAME "take backup ${BK_FROM} ${BK_TO}"
  else 
    gcloud logging write $STL_LOG_NAME "$MSG"
    gcloud logging write $STL_LOG_NAME "Failed bq_backup"
    exit 1
  fi
done

gcloud logging write $STL_LOG_NAME  "COMPLETED BACKUP"

