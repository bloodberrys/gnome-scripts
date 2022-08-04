#!/bin/bash

PROTOCOL=http://
DEST_IP=45.32.116.36 # this is gonna be a targeted server
PORT=81
ASSET_PATH=dev10release3/Patch/Seasia/Android/1.6.59/
URL_PREFIX=$PROTOCOL$DEST_IP:$PORT/$ASSET_PATH

LOCAL_ASSET_PATH=/var/www/html/dev10release3/Patch/Seasia/Android/1.6.59
TARGET_ASSET_PATH=/var/www/html/dev10release3/Patch/Seasia/Android/asset-download

cd $LOCAL_ASSET_PATH
ASSET_FILES=$(find * -maxdepth 10 -type f)

cd ../
mkdir -p $TARGET_ASSET_PATH
cd $TARGET_ASSET_PATH

cat <<EOF >files.txt
$ASSET_FILES
EOF

sed -i "s|^|$URL_PREFIX|g" files.txt

cat files.txt | xargs -n 1 -P 2 wget -q

rm -f files.txt

# Building the asset directories

IFS=" " read -r -a ASSET_DIRECTORIES <<< "1.6.1 1.6.11 1.6.14 1.6.19 1.6.38 1.6.40 1.6.43 1.6.47 1.6.57 1.6.59 1.6.8 1.6.9"

assetlength=${#ASSET_DIRECTORIES[@]}

declare -a TEMP_ASSET_MAPPING=()

for (( i = 0; i < assetlength; i++ ))
do
    # Define current loop asset
    DIR_ASSET=${ASSET_DIRECTORIES[$i]}/AssetBundles

    # list directory from source
    cd $LOCAL_ASSET_PATH/$DIR_ASSET
    CATCH_FILE_INSIDE_ASSET_DIR=$(find * -maxdepth 10 -type f)

    # Go to target directory
    cd $TARGET_ASSET_PATH

    # Create directory
    mkdir -p $DIR_ASSET

cat <<EOF >file_dir${ASSET_DIRECTORIES[$i]}.txt
$CATCH_FILE_INSIDE_ASSET_DIR
EOF

    cat file_dir${ASSET_DIRECTORIES[$i]}.txt | xargs -n 1 -d'\n' -I {} mv $TARGET_ASSET_PATH/{} $TARGET_ASSET_PATH/$DIR_ASSET/

    rm -f file_dir${ASSET_DIRECTORIES[$i]}.txt
done