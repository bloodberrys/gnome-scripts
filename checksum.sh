#!/bin/bash

IFS=" " read -r -a ASSET_DIRECTORIES <<< "1.44.26"

assetlength=${#ASSET_DIRECTORIES[@]}

for (( i = 0; i < assetlength; i++ ))
do
    cd /var/www/html/Official/Patch/Dev/Android/"${ASSET_DIRECTORIES[$i]}/AssetBundles"
    pwd=$(pwd)
    for file in "$pwd"/*; do
        echo "${file##*/}"
        file2=$(echo ${file#/var/www/html/Official/Patch/Dev/Android/})
        wget http://lzg.ssqlm.win:81/Official/Patch/Dev/Android/"$file2"
    done

    rm -rf *.ab
    chmod -R 777 *
    for file in *.1
    do
        mv "$file" "${file%.1}"
    done
done