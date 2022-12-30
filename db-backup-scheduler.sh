#!/bin/bash
# please run this as cron job root.

# set path for aws 
export PATH=$PATH:/snap/bin

dir="/tmp/dnmgnome-db-backup"

if [[ ! -e $dir ]]; then
    mkdir -p $dir
elif [[ ! -d $dir ]]; then
    echo "$dir already exists but is not a directory" 1>&2
fi

cd $dir

# Change timezone to jakarta WIB
export TZ=Asia/Jakarta
date=$(date '+%Y-%m-%d_%H-%M-%S_%Z')

# DB Creds
DB_HOSTNAME=dn-db.gnome-hub.internal
DB_USERNAME=gnome
DB_PASSWORD=Capcapcap123

# Backupdb
mysqldump -h $DB_HOSTNAME -u $DB_USERNAME -p$DB_PASSWORD --all-databases --single-transaction > db-$date.sql

# compress or zip file to reduce the storage cost
zip -9 db-$date.sql.zip db-$date.sql

# upload to s3
aws s3 cp db-$date.sql.zip s3://dnmgnome-db-backup

# remove 1 old file after success, we will retain atleast 1.
ls -t | sed -e '1,1d' | xargs -d '\n' -r rm