#!/bin/bash

usage() { echo "Usage: $CMDNAME -h hostname -P port -d database -u username -p password -k aws_key -s aws_secret -b bucket -r region" 1>&2; }

while getopts h:P:d:u:p: OPT
do
  case $OPT in
    "h" ) hostname="$OPTARG" ;;
    "P" ) port="$OPTARG" ;;
    "d" ) database="$OPTARG" ;;
    "u" ) username="$OPTARG" ;;
    "p" ) password="$OPTARG" ;;
    "k" ) access_key_id="$OPTARG" ;;
    "s" ) secret_access_key="$OPTARG" ;;
    "b" ) bucket="$OPTARG" ;;
    "r" ) region="$OPTARG" ;;
		* ) usage; exit 1 ;;
  esac
done

echo $hostname
echo $port
echo $database
echo $username
echo $password

DATE=`/bin/date '+%Y%m%d%H%M'`
BACKUP_DIR=/mnt/mongobackup/
sudo mkdir -p $BACKUP_DIR
sudo chown ubuntu:ubuntu $BACKUP_DIR

mkdir -p $BACKUP_DIR/$database
rm -fR $BACKUP_DIR/$database/*

echo "/usr/bin/mongodump -h $hostname:$port -d $database -u $username -p$password -o $BACKUP_DIR"
/usr/bin/mongodump -h $hostname:$port -d $database -u $username -p$password -o $BACKUP_DIR

# e.g. databasename.201104132331.tar.gz
BACKUP_FILE_NAME=$database.$DATE.tar.gz
cd $BACKUP_DIR
tar cvzf $BACKUP_FILE_NAME $database

echo "runurl https://github.com/wizardofcrowds/junks/raw/master/runurlables/upload2s3.rb -k access_key_id -s secret_access_key -b bucket -r region -f $BACKUP_FILE_NAME"
runurl https://github.com/wizardofcrowds/junks/raw/master/runurlables/upload2s3.rb -k access_key_id -s secret_access_key -b bucket -r region -f $BACKUP_FILE_NAME

