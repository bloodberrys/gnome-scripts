#!/bin/bash

PROTOCOL=http://
DEST_IP=lzg.ssqlm.win # this is gonna be a targeted server
PORT=81
ASSET_PATH=Official/Patch/Dev/Android/an/
URL_PREFIX=$PROTOCOL$DEST_IP:$PORT/$ASSET_PATH

TARGET_ASSET_PATH=/home/ec2-user/new_hurricane

cd $TARGET_ASSET_PATH

sed -i "s|^|$URL_PREFIX|g" hurricane-files.txt

HURRICANE_PATH_DOWNLOAD=path_for_hurricane_asset.txt

while read -r line
do
   curl $line --create-dirs -o $line
   path=$(cat $HURRICANE_PATH_DOWNLOAD | grep "${line##*/}")
   mkdir -p "${TARGET_ASSET_PATH}/http:/lzg.ssqlm.win:81/Official/Patch/Dev/Android/${path%/*}/"
   mv -f "$line" "${TARGET_ASSET_PATH}/http:/lzg.ssqlm.win:81/Official/Patch/Dev/Android/${path}"
done < hurricane-files.txt